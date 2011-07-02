# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      class Within < Validator

        attr_reader :set

        def initialize(attribute_name, options={})
          @set = options.fetch(:set, [])

          super(attribute_name, DataMapper::Ext::Hash.except(options, :set))
        end

        def call(resource)
          value = resource.validation_property_value(attribute_name)
          return true if optional?(value)
          return true if set.include?(value)

          error_message = self.custom_message || get_error_message

          add_error(resource, error_message, attribute_name)

          false
        end

      private
        # TODO: break this up into two validators: WithinRange & WithinSet
        # they will both inherit from within, and the Validators#validates_within
        # macro will inspect the :set arg and add the appropriate validator
        def get_error_message
          if set.is_a?(Range)
            error_message_for_range_set
          else
            ValidationErrors.default_error_message(:inclusion, attribute_name, set.to_a.join(', '))
          end
        end

        def error_message_for_range_set
          # TODO: just use Infinity directly here
          n = 1.0/0

          error_message_args =
            if set.first != -n && set.last != n
              [ :value_between,             attribute_name, set.first, set.last ]
            elsif set.first == -n
              [ :less_than_or_equal_to,     attribute_name, set.last ]
            elsif set.last == n
              [ :greater_than_or_equal_to,  attribute_name, set.first ]
            end

          ValidationErrors.default_error_message(*error_message_args)
        end

      end # class Within
    end # module Validators
  end # module Validations
end # module DataMapper
