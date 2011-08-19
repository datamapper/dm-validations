# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/length'

module DataMapper
  module Validation
    class Rule
      module Length

        class Range < Rule

          include Length

          attr_reader :expected

          def initialize(attribute_name, options)
            super

            @expected = options.fetch(:range)
          end

          def violation_type(resource)
            :length_between
          end

          def violation_data(resource)
            [ [ :min, expected.begin ], [ :max, expected.end ] ]
          end

        private

          # Validate the value length is within expected range
          #
          # @param [Integer] length
          #   the value length
          #
          # @return [String, NilClass]
          #   the error message if invalid, nil if valid
          #
          # @api private
          def valid_length?(length)
            expected.include?(length)
          end

        end # class Range

      end # module Length
    end # class Rule
  end # module Validation
end # module DataMapper
