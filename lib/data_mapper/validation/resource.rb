require 'data_mapper/core'
require 'data_mapper/validation'
require 'data_mapper/validation/context'

module DataMapper
  module Validation

    module Resource

      def self.included(model)
        model.before :save, :validate_or_halt
      end

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
      def save(context_name = default_validation_context)
        model.validators.assert_valid_context(context_name)

        Context.in_context(context_name) { super() }
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
      def update(attributes = {}, context_name = default_validation_context)
        model.validators.assert_valid_context(context_name)

        Context.in_context(context_name) { super(attributes) }
      end

      # @api private
      def validate_or_halt
        throw :halt if Context.any? && !valid?(model.validators.current_context)
      end

    end # module Resource
  end # module Validation

  Model.append_inclusions Validation
  Model.append_inclusions Validation::Resource

end
