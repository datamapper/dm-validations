# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class GreaterThanOrEqual < Validator

          include Numericalness

        private

          def validate_numericalness(value)
            validate_with_comparison(value)
          end

          def comparison
            :>=
          end

          def error_message_name
            :greater_than_or_equal_to
          end

        end # class GreaterThanOrEqual

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
