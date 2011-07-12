# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    class Validator

      module Length

        attr_reader :expected

        # TODO: DRY this up (also implemented in Validator)
        def self.validators_for(attribute_name, options)
          Array(new(attribute_name, options))
        end

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
            warn "expected length specification: one of :is, :equals, :within, :in, :minimum, :min, :maximum, or :max; got #{options.keys.inspect}"
            Length::Dummy.new(attribute_name, options)
          end
        end

        class Dummy < Validator
          include Length
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)

          if optional?(value)
            true
          else
            length = value_length(value.to_s)
            validate_length(length)
          end
        end

        def violation_data(resource)
          [ expected ]
        end

      private

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

    end # class Validator
  end # module Validations
end # module DataMapper

# meh, I don't like doing this, but the superclass must be loaded before subclasses
require 'data_mapper/validations/validator/length/equal'
require 'data_mapper/validations/validator/length/range'
require 'data_mapper/validations/validator/length/minimum'
require 'data_mapper/validations/validator/length/maximum'
