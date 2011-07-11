# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/numericalness'

module DataMapper
  module Validations
    class Validator
      module Numericalness

        class LessThanOrEqual < Validator

          include Numericalness

          def validate_numericalness(value)
            value <= expected
          rescue ArgumentError
            # TODO: figure out better solution for: can't compare String with Integer
            true
          end

          def error_message_args
            [ :less_than_or_equal_to, attribute_name, expected ]
          end

        end # class LessThanOrEqual

      end # module Numericalness
    end # class Validator
  end # module Validations
end # module DataMapper
