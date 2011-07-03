# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Absence < Validator

        def call(resource)
          return true if valid?(resource)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args)

          add_error(resource, error_message, attribute_name)
          false
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          DataMapper::Ext.blank?(value)
        end

        def error_message_args
          [ :absent, attribute_name ]
        end

      end # class Absence

    end # module Validators
  end # module Validations
end # module DataMapper
