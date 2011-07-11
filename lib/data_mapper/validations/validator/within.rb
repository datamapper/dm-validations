# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    class Validator

      class Within < Validator

        attr_reader :set

        def initialize(attribute_name, options={})
          @set = options.fetch(:set, [])

          super(attribute_name, DataMapper::Ext::Hash.except(options, :set))
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)

          optional?(value) || set.include?(value)
        end

        def error_message_args
          if set.is_a?(Range)
            if set.first != -Infinity && set.last != Infinity
              [ :value_between,             attribute_name, set.first, set.last ]
            elsif set.first == -Infinity
              [ :less_than_or_equal_to,     attribute_name, set.last ]
            elsif set.last == Infinity
              [ :greater_than_or_equal_to,  attribute_name, set.first ]
            end
          else
            [ :inclusion, attribute_name, set.to_a.join(', ') ]
          end
        end

      end # class Within

    end # class Validator
  end # module Validations
end # module DataMapper
