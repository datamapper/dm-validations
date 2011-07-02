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

        def call(target)
          return true if valid?(target)

          value = target.validation_property_value(attribute_name)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:invalid, attribute_name)

          add_error(
            target,
            error_message.try_call(humanized_field_name, value),
            attribute_name
          )
          false
        end

      private

        def valid?(target)
          value = target.validation_property_value(attribute_name)
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
              raise(UnknownValidationFormat, "Can't determine how to validate #{target.class}##{attribute_name} with #{validator.inspect}")
          end
        rescue Encoding::CompatibilityError
          # This is to work around a bug in jruby - see formats/email.rb
          false
        end

      end # class Format

    end # module Validators
  end # module Validations
end # module DataMapper
