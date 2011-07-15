# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/within/range'

module DataMapper
  module Validations
    class Rule
      module Within
        module Range

          class Bounded < Rule

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
    end # class Rule
  end # module Validations
end # module DataMapper
