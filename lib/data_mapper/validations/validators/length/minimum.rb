# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/length'

module DataMapper
  module Validations
    module Validators
      module Length
        class Minimum < Validator

          include Length

          attr_reader :minimum

          def initialize(attribute_name, options)
            @minimum = options[:minimum]
            # TODO: fix inheritance to delegate copying to Validator
            # instead of just passing options
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :minimum))
            super
          end

        private

          # Validate the minimum expected value length
          #
          # @param [Integer] length
          #   the value length
          #
          # @return [String, NilClass]
          #   the error message if invalid, nil if valid
          #
          # @api private
          def validate_length(length)
            return if minimum <= length

            ValidationErrors.default_error_message(
              :too_short,
              humanized_field_name,
              minimum
            )
          end

        end # class Minimum
      end # class Length
    end # module Validators
  end # module Validations
end # module DataMapper
