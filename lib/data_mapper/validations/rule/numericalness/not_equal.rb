# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/numericalness'

module DataMapper
  module Validations
    class Rule
      module Numericalness

        class NotEqual < Rule

          include Numericalness

          def validate_numericalness(value)
            value != expected
          rescue ArgumentError
            # TODO: figure out better solution for: can't compare String with Integer
            true
          end

          def violation_type(resource)
            :not_equal_to
          end

        end # class NotEqual

      end # module Numericalness
    end # class Rule
  end # module Validations
end # module DataMapper
