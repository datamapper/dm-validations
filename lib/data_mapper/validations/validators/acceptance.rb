# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Acceptance < Validator

        DEFAULT_ACCEPT_VALUES = [ '1', 1, 'true', true, 't' ]

        def initialize(attribute_name, options = {})
          super

          @options[:allow_nil] = true unless @options.key?(:allow_nil)

          @options[:accept] = Array(@options[:accept] || DEFAULT_ACCEPT_VALUES)
        end

        def call(resource)
          return true if valid?(resource)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args)

          add_error(resource, error_message, attribute_name)

          false
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if allow_nil?(value)
          @options[:accept].include?(value)
        end

        def error_message_args
          [ :accepted, attribute_name ]
        end

      private

        def allow_nil?(value)
          @options[:allow_nil] && value.nil?
        end

      end # class Acceptance

    end # module Validators
  end # module Validations
end # module DataMapper
