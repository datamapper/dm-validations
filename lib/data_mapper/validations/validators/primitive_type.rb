# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      class PrimitiveType < Validator

        def call(resource)
          value    = resource.validation_property_value(attribute_name)
          property = get_resource_property(resource, attribute_name)

          return true if value.nil? || property.primitive?(value)

          error_message = self.custom_message || default_error(property)
          add_error(resource, error_message, attribute_name)

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
