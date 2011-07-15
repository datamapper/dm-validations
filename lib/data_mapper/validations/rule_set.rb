require "data_mapper/support/ordered_set"

module DataMapper
  module Validations
    class RuleSet < OrderedSet
      # Holds a collection of Validator instances that should be run against
      # Resources to validate the Resources in a specific context


      # Execute all validators in this context against the resource.
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

        validators = validators_for_resource(resource)

        validators.map { |validator| validator.call(resource) }.all?
      end

      def inspect
        "#<#{ self.class } {#{ entries.map { |e| e.inspect }.join( ', ' ) }}>"
      end

    private

      def validators_for_resource(resource)
        executable_validators = entries.select { |v| v.execute?(resource) }

        # By default we start the list with the full set of executable
        # validators.
        #
        # In the case of a new Resource or regular ruby class instance,
        # everything needs to be validated completely, and no eager-loading
        # logic should apply.
        #
        # @see #validators_for_persisted_resource
        if resource.kind_of?(DataMapper::Resource) && !resource.new?
          validators_for_persisted_resource(resource, executable_validators)
        else
          executable_validators
        end
      end

      # In the case of a DM::Resource that isn't new, we optimize:
      #
      #   1. Eager-load all lazy, not-yet-loaded properties that need
      #      validation, all at once.
      #
      #   2. Limit run validators to
      #      - those applied to dirty attributes only,
      #      - those that should always run (presence/absence)
      #      - those that don't reference any real properties (attribute-less
      #        block validators, validations in virtual attributes)
      def validators_for_persisted_resource(resource, all_validators)
        attrs       = resource.attributes
        dirty_attrs = Hash[resource.dirty_attributes.map { |p, value| [p.name, value] }]
        validators  = all_validators.select { |v|
          !attrs.include?(v.attribute_name) || dirty_attrs.include?(v.attribute_name)
        }

        load_validated_properties(resource, validators)

        # Finally include any validators that should always run or don't
        # reference any real properties (field-less block vaildators).
        validators |= all_validators.select do |v|
          # TODO: make this a #always_validate? interface instead of a #kind_of? test
          v.kind_of?(Validator::Method) ||
          v.kind_of?(Validator::Presence) ||
          v.kind_of?(Validator::Absence)
        end

        validators
      end

      # Load all lazy, not-yet-loaded properties that need validation,
      # all at once.
      def load_validated_properties(resource, validators)
        properties = resource.model.properties

        properties_to_load = validators.map { |validator|
          properties[validator.attribute_name]
        }.compact.select { |property|
          property.lazy? && !property.loaded?(resource)
        }

        resource.__send__(:eager_load, properties_to_load)
      end
    end # class ValidationContext
  end # module Validations
end # module DataMapper
