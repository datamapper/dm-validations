# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      module Length
        # TODO: move options normalization into the validator macros
        def self.new(attribute_name, options)
          options = options.dup

          equal   = options.delete(:is)      || options.delete(:equals)
          range   = options.delete(:within)  || options.delete(:in)
          minimum = options.delete(:minimum) || options.delete(:min)
          maximum = options.delete(:maximum) || options.delete(:max)

          if minimum && maximum
            range ||= minimum..maximum
          end

          if equal
            Length::Equal.new(attribute_name,   options.merge(:equal => equal))
          elsif range
            Length::Range.new(attribute_name,   options.merge(:range => range))
          elsif minimum
            Length::Minimum.new(attribute_name, options.merge(:minimum => minimum))
          elsif maximum
            Length::Maximum.new(attribute_name, options.merge(:maximum => maximum))
          else
            # raise ArgumentError, "expected one of :is, :equals, :within, :in, :minimum, :min, :maximum, or :max; got #{options.keys.inspect}"
            warn "expected one of :is, :equals, :within, :in, :minimum, :min, :maximum, or :max; got #{options.keys.inspect}"
            Length::Dummy.new(attribute_name, options)
          end
        end

        class Dummy < Validator
          include Length
        end

        # Test the resource field for validity
        #
        # @example when the resource field is valid
        #   validator.call(valid_resource)  # => true
        #
        # @example when the resource field is not valid
        #   validator.call(invalid_resource)  # => false
        #
        #
        # @param [Resource] target
        #   the Resource to test
        #
        # @return [Boolean]
        #   true if the field is valid, false if not
        #
        # @api semipublic
        def call(target)
          value = target.validation_property_value(attribute_name)
          return true if optional?(value)

          return true unless error_message = error_message_for(value)

          add_error(target, error_message, attribute_name)
          false
        end

      private

        # Return the error messages for the value if it is invalid
        #
        # @param [#to_s] value
        #   the value to test
        #
        # @return [String, nil]
        #   the error message if invalid, nil if not
        #
        # @api private
        def error_message_for(value)
          length = value_length(value.to_s)

          if error_message = validate_length(length)
            self.custom_message || error_message
          end
        end

        def validate_length(length)
          raise NotImplementError, "#{self.class}#validate_length must be implemented"
        end

        # Return the length in characters
        #
        # @param [#to_str] value
        #   the string to get the number of characters for
        #
        # @return [Integer]
        #   the number of characters in the string
        #
        # @api private
        def value_length(value)
          value.to_str.length
        end

        if RUBY_VERSION < '1.9'
          def value_length(value)
            value.to_str.scan(/./u).size
          end
        end

      end # module Length
    end # module Validators
  end # module Validations
end # module DataMapper

# meh, I don't like doing this, but the superclass must be loaded before subclasses
require 'data_mapper/validations/validators/length/equal'
require 'data_mapper/validations/validators/length/range'
require 'data_mapper/validations/validators/length/minimum'
require 'data_mapper/validations/validators/length/maximum'
