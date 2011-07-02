# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class Equal < Validator

          include Numericalness

        private

          def validate_numericalness(value)
            validate_with_comparison(value)
          end

          def comparison
            :==
          end

          def error_message_name
            :equal_to
          end

        end # class Equal

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
