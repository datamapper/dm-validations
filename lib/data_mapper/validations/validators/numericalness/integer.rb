# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class Integer < Validator

          include Numericalness

          def expected
            /\A[+-]?\d+\z/
          end

        private

          def validate_numericalness(value)
            validate_with_comparison(value_as_string(value))
          end

          def comparison
            :=~
          end

          def error_message_name
            :not_an_integer
          end

        end # class Equal

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
