# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      class PrimitiveType < Validator

        def call(target)
          value    = target.validation_property_value(attribute_name)
          property = get_resource_property(target, attribute_name)

          return true if value.nil? || property.primitive?(value)

          error_message = self.custom_message || default_error(property)
          add_error(target, error_message, attribute_name)

          false
        end

      protected

        def default_error(property)
          ValidationErrors.default_error_message(
            :primitive,
            attribute_name,
            property.primitive
          )
        end

      end # class PrimitiveType
    end # module Validators
  end # module Validations
end # module DataMapper
