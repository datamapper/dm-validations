# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/length'

module DataMapper
  module Validations
    class Validator
      module Length

        class Minimum < Validator

          include Length

          attr_reader :expected

          def initialize(attribute_name, options)
            @expected = options[:minimum]
            # TODO: fix inheritance to delegate copying to Validator
            # instead of just passing options
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :minimum))
            super
          end

          def violation_type(resource)
            :too_short
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
            expected <= length
          end

        end # class Minimum

      end # module Length
    end # class Validator
  end # module Validations
end # module DataMapper
