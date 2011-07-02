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

        def call(target)
          return true if valid?(target)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:confirmation, attribute_name)
          add_error(target, error_message, attribute_name)

          false
        end

      private

        def valid?(target)
          value = target.validation_property_value(attribute_name)
          return true if optional?(value)

          if target.model.properties.named?(attribute_name)
            return true unless target.attribute_dirty?(attribute_name)
          end

          confirm_value = target.instance_variable_get("@#{@confirm_attribute_name}")
          value == confirm_value
        end

      end # class Confirmation

    end # module Validators
  end # module Validations
end # module DataMapper
