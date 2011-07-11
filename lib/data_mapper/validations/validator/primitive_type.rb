# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    class Validator

      class PrimitiveType < Validator

        def call(resource)
          value     = resource.validation_property_value(attribute_name)
          property  = get_resource_property(resource, attribute_name)
          primitive = property.primitive

          return true if valid?(property, value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args(primitive))

          add_error(resource, error_message, attribute_name)

          false
        end

        def valid?(property, value)
          value.nil? || property.primitive?(value)
        end

        def error_message_args(primitive)
          [ :primitive, attribute_name, primitive ]
        end

      end # class PrimitiveType

    end # class Validator
  end # module Validations
end # module DataMapper
