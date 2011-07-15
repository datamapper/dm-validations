require 'forwardable'
require 'data_mapper/support/ordered_set'
# TODO: can I use Equalizer without introducing a dependency on dm-core?
# require 'data_mapper/support/equalizer'

module DataMapper
  module Validations
    class RuleSet < OrderedSet
      extend Equalizer
      extend Forwardable
      include Enumerable

      attr_reader :name
      attr_reader :optimize
      attr_reader :rules
      attr_reader :attributes

      equalize :name, :rules

      def_delegators :attributes, :[]
      def_delegators :rules, :each, :empty?

      def initialize(name, optimize = false)
        @name     = name
        @optimize = optimize

        @rules      = OrderedSet.new
        @attributes = Hash.new { |h,k| h[k] = OrderedSet.new }
      end

      def <<(rule)
        unless rules.include?(rule)
          rules << rule
          attributes[rule.attribute_name] << rule
        end

        self
      end

      # Holds a collection of Validator instances that should be run against
      # Resources to validate the Resources in a specific context


      # Execute all rules in this context against the resource.
      # 
      # Only validate dirty properties on persisted Resources.
      # Eager load lazy properties that not yet loaded.
      #
      # @param [Object] resource
      #   the resource that we are validating
      # 
      # @return [Boolean]
      #   true if all are valid, otherwise false
      def validate(resource)
        resource.errors.clear!

        rules = rules_for_resource(resource)

        rules.map { |rule| rule.call(resource) }.all?
      end

      def inspect
        "#<#{ self.class } {#{ rules.map { |e| e.inspect }.join( ', ' ) }}>"
      end

    private

      def rules_for_resource(resource)
        executable_rules = rules.entries.select { |v| v.execute?(resource) }

        # By default we start the list with the full set of executable
        # rules.
        #
        # In the case of a new Resource or regular ruby class instance,
        # everything needs to be validated completely, and no eager-loading
        # logic should apply.
        #
        # @see #rules_for_persisted_resource
        if optimize && resource.kind_of?(DataMapper::Resource) && !resource.new?
          rules_for_persisted_resource(resource, executable_rules)
        else
          executable_rules
        end
      end

      # In the case of a DM::Resource that isn't new, we optimize:
      #
      #   1. Eager-load all lazy, not-yet-loaded properties that need
      #      validation, all at once.
      #
      #   2. Limit run rules to
      #      - those applied to dirty attributes only,
      #      - those that should always run (presence/absence)
      #      - those that don't reference any real properties (attribute-less
      #        block rules, validations in virtual attributes)
      def rules_for_persisted_resource(resource, executable_rules)
        attrs       = resource.attributes(:name)
        # TODO: update Resource#dirty_attributes to accept :name arg
        dirty_attrs = Hash[resource.dirty_attributes.map { |p, value| [p.name, value] }]
        rules       = executable_rules.select { |v|
          !attrs.include?(v.attribute_name) || dirty_attrs.include?(v.attribute_name)
        }

        load_validated_properties(resource, rules)

        # Finally include any rules that should always run or don't
        # reference any real properties (field-less block vaildators).
        rules |= all_rules.select do |v|
          # TODO: make this a #always_validate? interface instead of a #kind_of? test
          v.kind_of?(Validator::Method) ||
          v.kind_of?(Validator::Presence) ||
          v.kind_of?(Validator::Absence)
        end

        rules
      end

      # Load all lazy, not-yet-loaded properties that need validation,
      # all at once.
      def load_validated_properties(resource, rules)
        properties = resource.model.properties

        properties_to_load = rules.map { |rule|
          properties[rule.attribute_name]
        }.compact.select { |property|
          property.lazy? && !property.loaded?(resource)
        }

        resource.__send__(:eager_load, properties_to_load)
      end
    end # class RuleSet
  end # module Validations
end # module DataMapper
