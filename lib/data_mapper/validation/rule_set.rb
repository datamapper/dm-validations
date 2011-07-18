require 'forwardable'
require 'data_mapper/support/ordered_set'
# TODO: can I use Equalizer without introducing a dependency on dm-core?
# require 'data_mapper/support/equalizer'

module DataMapper
  module Validation

    class RuleSet
      # Holds a collection of Rule instances to be run against
      # Resources to validate the Resources in a specific context

      extend Equalizer
      extend Forwardable
      include Enumerable

      # @api public
      attr_reader :rules

      # @api private
      attr_reader :attribute_index

      # @api public
      attr_accessor :optimize

      equalize :rules

      # @api public
      def_delegators :attribute_index, :[]

      # @api public
      def_delegators :rules, :each, :empty?

      def initialize(optimize = false)
        @optimize = optimize

        @rules           = OrderedSet.new
        @attribute_index = Hash.new { |h,k| h[k] = [] }
      end

      def <<(rule)
        unless rules.include?(rule)
          rules << rule
          attribute_index[rule.attribute_name] << rule
        end

        self
      end

      # Execute all rules in this context against the resource.
      # 
      # @param [Object] resource
      #   the resource to be validated
      # 
      # @return [Array(Violation)]
      #   an Array of Violations
      def validate(resource)
        rules = rules_for_resource(resource)
        rules.map { |rule| rule.validate(resource) }.compact
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
        # @see #optimized_rules_for_persisted_resource
        if resource.kind_of?(DataMapper::Resource)
          if optimize && !resource.new?
            optimized_rules = optimized_rules_for_persisted_resource(resource, executable_rules)
            load_validated_properties(resource, optimized_rules)
            optimized_rules
          else
            load_validated_properties(resource, executable_rules)
            executable_rules
          end
        else
          executable_rules
        end
      end

      # Only validate dirty properties on persisted Resources.
      # Eager load lazy properties that are not yet loaded.
      #
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
      def optimized_rules_for_persisted_resource(resource, executable_rules)
        attrs       = resource.attributes(:name)
        # TODO: update Resource#dirty_attributes to accept :name arg
        dirty_attrs = Hash[resource.dirty_attributes.map { |p, value| [p.name, value] }]
        rules       = executable_rules.select { |r|
          !attrs.include?(r.attribute_name) || dirty_attrs.include?(r.attribute_name)
        }

        # Finally include any rules that should always run or don't
        # reference any real properties (field-less block vaildators).
        rules |= all_rules.select do |v|
          # TODO: make this a #always_validate? interface instead of a #kind_of? test
          v.kind_of?(Rule::Method) ||
          v.kind_of?(Rule::Presence) ||
          v.kind_of?(Rule::Absence)
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

  end # module Validation
end # module DataMapper
