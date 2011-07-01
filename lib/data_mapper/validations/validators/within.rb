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

        def call(target)
          value = target.validation_property_value(attribute_name)
          return true if optional?(value)
          return true if set.include?(value)

          error_message = self.custom_message || get_error_message

          add_error(target, error_message, attribute_name)

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


      # Validates that the value of a field is within a range/set.
      #
      # This validation is defined by passing a field along with a :set
      # parameter. The :set can be a Range or any object which responds
      # to the #include? method (an array, for example).
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Review
      #     include DataMapper::Resource
      #
      #     STATES = ['new', 'in_progress', 'published', 'archived']
      #
      #     property :title, String
      #     property :body, String
      #     property :review_state, String
      #     property :rating, Integer
      #
      #     validates_within :review_state, :set => STATES
      #     validates_within :rating,       :set => 1..5
      #
      #     # a call to valid? will return false unless
      #     # the two properties conform to their sets
      #   end
      def validates_within(*fields)
        validators.add(Validators::Within, *fields)
      end

    end # module Validators
  end # module Validations
end # module DataMapper
