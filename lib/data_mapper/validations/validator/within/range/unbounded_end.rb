# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/within/range'

module DataMapper
  module Validations
    class Validator
      module Within
        module Range

          class UnboundedEnd < Validator

            include Range

            def error_message_args
              [ :greater_than_or_equal_to, attribute_name, range.first ]
            end

          end # class UnboundedBegin

        end # module Range
      end # module Within
    end # class Validator
  end # module Validations
end # module DataMapper
