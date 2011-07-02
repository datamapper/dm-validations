# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class Numeric < Validator

          include Numericalness

          attr_reader :precision
          attr_reader :scale

          def initialize(attribute_name, options)
            super

            @precision = options[:precision]
            @scale     = options[:scale]

            @expected =
              if precision && scale
                if precision > scale && scale == 0
                  /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
                elsif precision > scale
                  /\A[+-]?(?:\d{1,#{precision - scale}}|\d{0,#{precision - scale}}\.\d{1,#{scale}})\z/
                elsif precision == scale
                  /\A[+-]?(?:0(?:\.\d{1,#{scale}})?)\z/
                else
                  raise ArgumentError, "Invalid precision #{precision.inspect} and scale #{scale.inspect} for #{attribute_name}"
                end
              else
                /\A[+-]?(?:\d+|\d*\.\d+)\z/
              end
          end

        private

          def validate_numericalness(value)
            validate_with_comparison(value_as_string(value))
          end

          def comparison
            :=~
          end

          def error_message_name
            :not_a_number
          end

        end # class Numeric

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
