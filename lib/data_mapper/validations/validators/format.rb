# -*- encoding: utf-8 -*-

require 'pathname'

require 'data_mapper/validations/validator'

require 'data_mapper/validations/validators/formats/email'
require 'data_mapper/validations/validators/formats/url'

module DataMapper
  module Validations
    class UnknownValidationFormat < ::ArgumentError; end

    module Validators

      class Format < Validator

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :format

        equalize *EQUALIZE_ON

        FORMATS = {
          :email_address => [
            Validators::Formats::EmailAddress,
            lambda { |field, value|
              '%s is not a valid email address'.t(value)
            }
          ],
          :url => [
            Validators::Formats::Url,
            lambda { |field, value|
              '%s is not a valid URL'.t(value)
            }
          ]
        }

        include DataMapper::Validations::Validators::Formats::Email
        include DataMapper::Validations::Validators::Formats::Url

        attr_reader :format

        # @raise [UnknownValidationFormat]
        #   if the :as (or :with) option is a Symbol that is not a key in FORMATS
        #   or if the provided format is not a Regexp, Symbol or Proc
        def initialize(attribute_name, options = {})
          format = options[:as] || options[:with]
          @format = 
            case format
            when Symbol
              FORMATS.fetch(format) do
                raise UnknownValidationFormat, "No such predefined format '#{format}'"
              end[0]
            when Proc, Regexp
              format
            else
              raise UnknownValidationFormat, "Expected a Regexp, Symbol, or Proc format. Got: #{format.inspect}"
            end

          super(attribute_name, DataMapper::Ext::Hash.except(options, :as, :with))

          allow_nil!   unless defined?(@allow_nil)
          allow_blank! unless defined?(@allow_blank)
        end

        def call(resource)
          value = resource.validation_property_value(attribute_name)
          return true if valid?(value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args)

          add_error(
            resource,
            error_message.try_call(humanized_field_name, value),
            attribute_name
          )
          false
        end

        def valid?(value)
          return true if optional?(value)

          format = self.format
          case format
          when Proc   then format.call(value)
          when Regexp then (value.kind_of?(Numeric) ? value.to_s : value) =~ format
          end
        rescue Encoding::CompatibilityError
          # This is to work around a bug in jruby - see formats/email.rb
          false
        end

        def error_message_args
          [ :invalid, attribute_name ]
        end

        # TODO: integrate format into error message key?
        def error_message_args
          if format.is_a?(Symbol)
            [ :"invalid_#{format}", attribute_name ]
          else
            [ :invalid, attribute_name ]
          end
        end

      end # class Format

    end # module Validators
  end # module Validations
end # module DataMapper
