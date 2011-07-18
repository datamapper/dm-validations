# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/length'

module DataMapper
  module Validation
    class Rule
      module Length

        class Equal < Rule

          include Length

          def initialize(attribute_name, options)
            super

            @expected = options[:equal]
          end

          def violation_type(resource)
            :wrong_length
          end

        private

          # Validate the value length is equal to the expected length
          #
          # @param [Integer] length
          #   the value length
          #
          # @return [String, nil]
          #   the error message if invalid, nil if not
          #
          # @api private
          def valid_length?(length)
            expected == length
          end

        end # class Equal

      end # module Length
    end # class Rule
  end # module Validation
end # module DataMapper
