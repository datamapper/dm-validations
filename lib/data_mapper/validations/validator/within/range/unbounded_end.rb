# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/within/range'

module DataMapper
  module Validations
    class Validator
      module Within
        module Range

          class UnboundedEnd < Validator

            include Range

            def violation_type(resource)
              :greater_than_or_equal_to
            end

            def violation_data(resource)
              [ range.begin ]
            end

          end # class UnboundedBegin

        end # module Range
      end # module Within
    end # class Validator
  end # module Validations
end # module DataMapper
