# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Acceptance < Validator

        def initialize(attribute_name, options = {})
          super

          @options[:allow_nil] = true unless @options.key?(:allow_nil)

          @options[:accept] ||= [ '1', 1, 'true', true, 't' ]
          @options[:accept] = Array(@options[:accept])
        end

        def call(target)
          return true if valid?(target)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:accepted, attribute_name)
          add_error(target, error_message, attribute_name)

          false
        end

      private

        def valid?(target)
          value = target.validation_property_value(attribute_name)
          return true if allow_nil?(value)
          @options[:accept].include?(value)
        end

        def allow_nil?(value)
          @options[:allow_nil] && value.nil?
        end

      end # class Acceptance

    end # module Validators
  end # module Validations
end # module DataMapper
