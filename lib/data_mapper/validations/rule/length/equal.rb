# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/length'

module DataMapper
  module Validations
    class Rule
      module Length

        class Equal < Rule

          include Length

          def initialize(attribute_name, options)
            @expected = options[:equal]
            # super(attribute_name, DataMapper::Ext::Hash.except(options, :equal))
            super
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
          def validate_length(length)
            expected == length
          end

        end # class Equal

      end # module Length
    end # class Rule
  end # module Validations
end # module DataMapper
