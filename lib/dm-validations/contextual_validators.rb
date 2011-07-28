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
      def_delegators :@attributes, :[]
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
        validator_options = DataMapper::Ext::Hash.except(options, :context)

        attributes.each do |attribute|
          # TODO: is :context part of the Validator state (ie, intrinsic),
          # or is it just membership in a collection?
          validator = validator_class.new(attribute, validator_options)
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
        ].compact.first

        options[:context] = Array(context || :default)
        options.update(defaults) unless defaults.nil?
        options
      end

      # Returns the current validation context on the stack if valid for this model,
      # nil if no contexts are defined for the model (and no contexts are on
      # the validation stack), or :default if the current context is invalid for
      # this model or no contexts have been defined for this model and
      # no context is on the stack.
      #
      # @return [Symbol]
      #   the current validation context from the stack (if valid for this model),
      #   nil if no context is on the stack and no contexts are defined for this model,
      #   or :default if the context on the stack is invalid for this model or
      #   no context is on the stack and this model has at least one validation context
      #
      # @api private
      #
      # TODO: simplify the semantics of #current_context, #valid?
      def current_context
        context = Validations::Context.current
        valid_context?(context) ? context : :default
      end

      # Test if the context is valid for the model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @return [Boolean]
      #   true if the context is valid for the model
      #
      # @api private
      #
      # TODO: investigate removing the `contexts.empty?` test here.
      def valid_context?(context)
        contexts.empty? || contexts.include?(context)
      end

      # Assert that the given context is valid for this model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @raise [InvalidContextError]
      #   raised if the context is not valid for this model
      #
      # @api private
      #
      # TODO: is this method actually needed?
      def assert_valid(context)
        unless valid_context?(context)
          raise InvalidContextError, "#{context} is an invalid context, known contexts are #{contexts.keys.inspect}"
        end
      end

      # Execute all validators in the named context against the target.
      # Load together any properties that are designated lazy but are not
      # yet loaded.
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

        # In the case of a new Resource or regular ruby class instance,
        # everything needs to be validated completely, and no eager-loading
        # logic should apply.
        #
        if target.kind_of?(DataMapper::Resource) && !target.new?
          load_validated_properties(target, executable_validators)
        end
        executable_validators.map { |validator| validator.call(target) }.all?
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
