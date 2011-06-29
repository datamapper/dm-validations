# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      class Within < Validator

        attr_reader :set

        def initialize(field_name, options={})
          super

          @set = @options.fetch(:set, [])
        end

        def call(target)
          value = target.validation_property_value(field_name)
          return true if optional?(value)
          return true if set.include?(value)

          error_message = @options[:message] || self.error_message

          add_error(target, error_message, field_name)

          false
        end

      private

        def error_message
          if set.is_a?(Range)
            error_message_for_range_set
          else
            ValidationErrors.default_error_message(:inclusion, field_name, set.to_a.join(', '))
          end
        end

        def error_message_for_range_set
          # TODO: just use Infinity directly here
          n = 1.0/0

          if set.first != -n && set.last != n
            ValidationErrors.default_error_message(:value_between, field_name, set.first, set.last)
          elsif set.first == -n
            ValidationErrors.default_error_message(:less_than_or_equal_to, field_name, set.last)
          elsif set.last == n
            ValidationErrors.default_error_message(:greater_than_or_equal_to, field_name, set.first)
          end
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
