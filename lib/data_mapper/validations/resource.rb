require 'data_mapper/validations'
require 'data_mapper/validations/context'
require 'data_mapper/validations/error_set'

module DataMapper
  module Validations
    module Resource
      # Ensures the object is valid for the context provided, and otherwise
      # throws :halt and returns false.
      #
      # @param [Symbol] context
      #   context for which to validate the Resource, defaulting to
      #   #default_validation_context
      # 
      # @return [Boolean]
      #   whether the Resource was persisted successfully
      # 
      # TODO: fix this to not change the method signature of #save
      #
      # @api public
      def save(context = default_validation_context)
        model.validators.assert_valid(context)
        Context.in_context(context) { super() }
      end

      # Ensures the object is valid for the context provided, and otherwise
      # throws :halt and returns false.
      #
      # @param [Hash] attributes
      #   attribute names and values which will be set on this Resource
      # @param [Symbol] context
      #   context for which to validate the Resource, defaulting to
      #   #default_validation_context
      #
      # @return [Boolean]
      #   whether the Resource attributes were set and persisted successfully
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
    end # module Resource
  end # module Validations

  Model.append_inclusions Validations
  Model.append_inclusions Validations::Resource

end
