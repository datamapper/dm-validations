# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Confirmation < Validator

        def initialize(attribute_name, options = {})
          super

          set_optional_by_default

          @confirm_attribute_name = (
            options[:confirm] || "#{attribute_name}_confirmation"
          ).to_sym
        end

        def call(resource)
          return true if valid?(resource)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:confirmation, attribute_name)
          add_error(resource, error_message, attribute_name)

          false
        end

      private

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if optional?(value)

          if resource.model.properties.named?(attribute_name)
            return true unless resource.attribute_dirty?(attribute_name)
          end

          confirm_value = resource.instance_variable_get("@#{@confirm_attribute_name}")
          value == confirm_value
        end

      end # class Confirmation

    end # module Validators
  end # module Validations
end # module DataMapper
