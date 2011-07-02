# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/length'

module DataMapper
  module Validations
    module Validators
      module Length
        class Range < Validator

          include Length

          attr_reader :range

          def initialize(attribute_name, options)
            @range = options[:range]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :range))
            super
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
          def validate_length(length)
            return if range.include?(length)

            ValidationErrors.default_error_message(
              :length_between,
              humanized_field_name,
              range.min,
              range.max
            )
          end

        end # class Range
      end # class Length
    end # module Validators
  end # module Validations
end # module DataMapper
