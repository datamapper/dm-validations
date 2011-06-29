require 'data_mapper/validations/context'
require 'data_mapper/validations/validation_errors'

module DataMapper
  module Validations
    module Resource

      # Ensures the object is valid for the context provided, and otherwise
      # throws :halt and returns false.
      #
      # TODO: fix this to not change the method signature of #save
      #
      # @api public
      def save(context = default_validation_context)
        model.validators.assert_valid(context)
        Context.in_context(context) { super() }
      end

      #
      # TODO: fix this to not change the method signature of #update
      #
      # @api public
      def update(attributes = {}, context = default_validation_context)
        model.validators.assert_valid(context)
        Context.in_context(context) { super(attributes) }
      end

      # @api private
      def save_self(*)
        if dirty_self? && Context.any? && !validate(model.validators.current_context)
          false
        else
          super
        end
      end

      # Return the ValidationErrors
      #
      # @api public
      def errors
        @errors ||= ValidationErrors.new(self)
      end

      # Mark this resource as validatable. When we validate associations of a
      # resource we can check if they respond to validatable? before trying to
      # recursively validate them
      #
      # @api semipublic
      def validatable?
        true
      end

      # Check if a resource is valid in a given context
      #
      # @api public
      def validate(context = :default)
        model = respond_to?(:model) ? self.model : self.class
        validation_context = model.validators.context(context)
        validation_context.validate(self)
      end

      # TODO: replace all internal uses of #valid? with #validate
      alias_method :valid?, :validate

      # Alias for validate(:default)
      #
      # TODO: deprecate
      # 
      # @api public
      def valid_for_default?
        validate(:default)
      end

      # @api public
      def validation_property_value(name)
        __send__(name) if respond_to?(name, true)
      end

      # The default validation context for this Resource.
      # This Resource's default context can be overridden by implementing
      # #default_validation_context
      # 
      # @return [Symbol]
      #   the current validation context from the context stack
      #   (if valid for this model), or :default
      # 
      # @api semipublic
      def default_validation_context
        model.validators.current_context || :default
      end

    end # module Resource
  end # module Validations

  Model.append_inclusions Validations::Resource

end
