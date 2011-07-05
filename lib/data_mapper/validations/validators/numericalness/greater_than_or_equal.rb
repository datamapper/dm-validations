# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class GreaterThanOrEqual < Validator

          include Numericalness

          def validate_numericalness(value)
            value >= expected
          rescue ArgumentError
            # TODO: figure out better solution for: can't compare String with Integer
            true
          end

          def error_message_args
            [ :greater_than_or_equal_to, attribute_name, expected ]
          end

        end # class GreaterThanOrEqual

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
