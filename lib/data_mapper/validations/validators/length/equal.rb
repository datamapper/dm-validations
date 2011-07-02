# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/length'

module DataMapper
  module Validations
    module Validators
      module Length

        class Equal < Validator

          include Length

          attr_reader :equal

          def initialize(attribute_name, options)
            @equal = options[:equal]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :equal))
            super
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
          def validate_length(length)
            return if equal == length

            ValidationErrors.default_error_message(
              :wrong_length,
              humanized_field_name,
              equal
            )
          end

        end # class Equal

      end # module Length
    end # module Validators
  end # module Validations
end # module DataMapper
