# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Absence < Validator

        def call(resource)
          value = resource.validation_property_value(attribute_name)
          return true if DataMapper::Ext.blank?(value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:absent, attribute_name)
          add_error(resource, error_message, attribute_name)
          false
        end

      end # class Absence

    end # module Validators
  end # module Validations
end # module DataMapper
