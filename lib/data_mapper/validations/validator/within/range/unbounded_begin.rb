# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/within/range'

module DataMapper
  module Validations
    class Validator
      module Within
        module Range

          class UnboundedBegin < Validator

            include Range

            def violation_type(resource)
              :less_than_or_equal_to
            end

            def violation_data(resource)
              [ range.end ]
            end

          end # class UnboundedBegin

        end # module Range
      end # module Within
    end # class Validator
  end # module Validations
end # module DataMapper
