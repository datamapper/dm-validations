# -*- encoding: utf-8 -*-

require 'pathname'

require 'data_mapper/validations/validator'

require 'data_mapper/validations/formats/email'
require 'data_mapper/validations/formats/url'

module DataMapper
  module Validations
    class UnknownValidationFormat < ::ArgumentError; end

    module Validators

      class Format < Validator

        FORMATS = {}

        include DataMapper::Validations::Format::Email
        include DataMapper::Validations::Format::Url

        def initialize(attribute_name, options = {})
          super

          set_optional_by_default
        end

        def call(resource)
          return true if valid?(resource)

          value = resource.validation_property_value(attribute_name)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args)

          add_error(
            resource,
            error_message.try_call(humanized_field_name, value),
            attribute_name
          )
          false
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if optional?(value)

          validation = @options[:as] || @options[:with]

          if validation.is_a?(Symbol) && !FORMATS.has_key?(validation)
            raise("No such predefined format '#{validation}'")
          end

          validator = if validation.is_a?(Symbol)
                        FORMATS[validation][0]
                      else
                        validation
                      end

          case validator
            when Proc   then validator.call(value)
            when Regexp then (value.kind_of?(Numeric) ? value.to_s : value) =~ validator
            else
              raise(UnknownValidationFormat, "Can't determine how to validate #{resource.class}##{attribute_name} with #{validator.inspect}")
          end
        rescue Encoding::CompatibilityError
          # This is to work around a bug in jruby - see formats/email.rb
          false
        end

        def error_message_args
          [ :invalid, attribute_name ]
        end

      end # class Format

    end # module Validators
  end # module Validations
end # module DataMapper
