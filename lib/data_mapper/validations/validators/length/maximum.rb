# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/length'

module DataMapper
  module Validations
    module Validators
      module Length

        class Maximum < Validator

          include Length

          attr_reader :expected

          def initialize(attribute_name, options)
            @expected = options[:maximum]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :maximum))
            super
          end

          def error_message_args
            [ :too_long, humanized_field_name, expected ]
          end

        private

          # Validate the maximum expected value length
          #
          # @param [Integer] length
          #   the value length
          #
          # @return [String, NilClass]
          #   the error message if invalid, nil if valid
          #
          # @api private
          def validate_length(length)
            expected >= length
          end

        end # class Maximum

      end # module Length
    end # module Validators
  end # module Validations
end # module DataMapper
