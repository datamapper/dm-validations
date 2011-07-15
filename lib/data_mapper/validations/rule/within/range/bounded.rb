# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/within/range'

module DataMapper
  module Validations
    class Validator
      module Within
        module Range

          class Bounded < Validator

            include Range

            def violation_type(resource)
              :value_between
            end

            def violation_data(resource)
              [ range.first, range.last ]
            end

          end # class Bounded

        end # module Range
      end # module Within
    end # class Validator
  end # module Validations
end # module DataMapper
