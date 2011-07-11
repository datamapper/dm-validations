# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/length'

module DataMapper
  module Validations
    class Validator
      module Length

        class Equal < Validator

          include Length

          def initialize(attribute_name, options)
            @expected = options[:equal]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :equal))
            super
          end

          def error_message_args
            [ :wrong_length, humanized_field_name, expected ]
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
            expected == length
          end

        end # class Equal

      end # module Length
    end # class Validator
  end # module Validations
end # module DataMapper
