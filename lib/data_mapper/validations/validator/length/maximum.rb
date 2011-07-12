# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/length'

module DataMapper
  module Validations
    class Validator
      module Length

        class Maximum < Validator

          include Length

          attr_reader :expected

          def initialize(attribute_name, options)
            @expected = options[:maximum]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :maximum))
            super
          end

          def violation_type(resource)
            :too_long
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
    end # class Validator
  end # module Validations
end # module DataMapper
