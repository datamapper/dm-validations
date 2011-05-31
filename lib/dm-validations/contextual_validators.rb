require 'forwardable'

module DataMapper
  module Validations
    #
    # @author Guy van den Berg
    # @since  0.9
    class ContextualValidators
      extend Forwardable

      #
      # Delegators
      #

      def_delegators :@contexts, :empty?, :each
      include Enumerable

      attr_reader :contexts, :attributes

      def initialize(model = nil)
        @model      = model
        @contexts   = {}
        @attributes = {}
      end

      #
      # API
      #

      # Return an array of validators for a named context
      #
      # @param  [String]
      #   Context name for which to return validators
      # @return [Array<DataMapper::Validations::GenericValidator>]
      #   An array of validators bound to the given context
      def context(name)
        contexts[name] ||= OrderedSet.new
      end

      # Return an array of validators for a named property
      #
      # @param [Symbol]
      #   Property name for which to return validators
      # @return [Array<DataMapper::Validations::GenericValidator>]
      #   An array of validators bound to the given property
      def attribute(name)
        attributes[name] ||= OrderedSet.new
      end

      # Clear all named context validators off of the resource
      #
      def clear!
        contexts.clear
        attributes.clear
      end

      # Create a new validator of the given klazz and push it onto the
      # requested context for each of the attributes in +attributes+
      # 
      # @param [DataMapper::Validations::GenericValidator] validator_class
      #    Validator class, example: DataMapper::Validations::LengthValidator
      #
      # @param [Array<Symbol>] attributes
      #    Attribute names given to validation macro, example:
      #    [:first_name, :last_name] in validates_presence_of :first_name, :last_name
      # 
      # @param [Hash] options
      #    Options supplied to validation macro, example:
      #    {:context=>:default, :maximum=>50, :allow_nil=>true, :message=>nil}
      # 
      # @option [Symbol] :context
      #   the context in which the new validator should be run
      # @option [Boolean] :allow_nil
      #   whether or not the new validator should allow nil values
      # @option [Boolean] :message
      #   the error message the new validator will provide on validation failure
      def add(validator_class, *attributes)
        options = attributes.last.kind_of?(Hash) ? attributes.pop.dup : {}
        normalize_options(options)

        attributes.each do |attribute|
          validator = validator_class.new(attribute, options.dup)
          attribute_validators = self.attribute(attribute)
          attribute_validators << validator unless attribute_validators.include?(validator)

          options[:context].each do |context|
            context_validators = self.context(context)
            next if context_validators.include?(validator)
            context_validators << validator
            # TODO: eliminate this, then eliminate the @model ivar entirely
            Validations::ClassMethods.create_context_instance_methods(@model, context) if @model
          end
        end
      end

      # Clean up the argument list and return a opts hash, including the
      # merging of any default opts. Set the context to default if none is
      # provided. Also allow :context to be aliased to :on, :when & :group
      # 
      # @param [Hash] options
      #   the options to be normalized
      # @param [NilClass, Hash] defaults
      #   default keys/values to set on normalized options
      # 
      # @return [Hash]
      #   the normalized options
      # 
      # @api private
      def normalize_options(options, defaults = nil)
        context = [
          options.delete(:group),
          options.delete(:on),
          options.delete(:when),
          options.delete(:context)
        ].compact.first || :default

        options[:context] = Array(context)
        options.update(defaults) unless defaults.nil?
        options
      end

      # Execute all validators in the named context against the target.
      # Load together any properties that are designated lazy but are not
      # yet loaded. Optionally only validate dirty properties.
      #
      # @param [Symbol] named_context
      #   the context we are validating against
      # @param [Object] target
      #   the resource that we are validating
      # @return [Boolean]
      #   true if all are valid, otherwise false
      def execute(named_context, target)
        target.errors.clear!

        available_validators  = context(named_context)
        executable_validators = available_validators.select { |v| v.execute?(target) }

        # By default we start the list with the full set of executable
        # validators.
        #
        # In the case of a new Resource or regular ruby class instance,
        # everything needs to be validated completely, and no eager-loading
        # logic should apply.
        #
        # @see #validators_for_resource
        validators = 
          if target.kind_of?(DataMapper::Resource) && !target.new?
            validators_for_resource(target, executable_validators)
          else
            executable_validators
          end

        validators.map { |validator| validator.call(target) }.all?
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
      def validators_for_resource(resource, all_validators)
        attrs       = resource.attributes
        dirty_attrs = Hash[resource.dirty_attributes.map { |p, value| [p.name, value] }]
        validators  = all_validators.select { |v|
          !attrs.include?(v.field_name) || dirty_attrs.include?(v.field_name)
        }

        load_validated_properties(resource, validators)

        # Finally include any validators that should always run or don't
        # reference any real properties (field-less block vaildators).
        validators |= all_validators.select do |v|
          v.kind_of?(MethodValidator) ||
          v.kind_of?(PresenceValidator) ||
          v.kind_of?(AbsenceValidator)
        end

        validators
      end

      # Load all lazy, not-yet-loaded properties that need validation,
      # all at once.
      def load_validated_properties(resource, validators)
        properties = resource.model.properties

        properties_to_load = validators.map { |validator|
          properties[validator.field_name]
        }.compact.select { |property|
          property.lazy? && !property.loaded?(resource)
        }

        resource.__send__(:eager_load, properties_to_load)
      end

    end # module ContextualValidators
  end # module Validations
end # module DataMapper
