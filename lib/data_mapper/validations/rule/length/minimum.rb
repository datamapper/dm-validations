# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/length'

module DataMapper
  module Validations
    class Rule
      module Length

        class Minimum < Rule

          include Length

          attr_reader :expected

          def initialize(attribute_name, options)
            @expected = options[:minimum]
            # TODO: fix inheritance to delegate copying to Rule
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
          def valid_length?(length)
            expected <= length
          end

        end # class Minimum

      end # module Length
    end # class Rule
  end # module Validations
end # module DataMapper
