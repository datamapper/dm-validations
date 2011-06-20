module DataMapper
  module Validations
    # @author Guy van den Berg
    # @since  0.9
    class WithinValidator < GenericValidator

      def initialize(field_name, options={})
        super

        @options[:set] = [] unless @options.has_key?(:set)
      end

      def call(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)
        return true if @options[:set].include?(value)

        n = 1.0/0
        set = @options[:set]
        msg = @options[:message]

        if set.is_a?(Range)
          if set.first != -n && set.last != n
            error_message = msg || ValidationErrors.default_error_message(:value_between, field_name, set.first, set.last)
          elsif set.first == -n
            error_message = msg || ValidationErrors.default_error_message(:less_than_or_equal_to, field_name, set.last)
          elsif set.last == n
            error_message = msg || ValidationErrors.default_error_message(:greater_than_or_equal_to, field_name, set.first)
          end
        else
          error_message = msg || ValidationErrors.default_error_message(:inclusion, field_name, set.to_a.join(', '))
        end

        add_error(target, error_message, field_name)

        false
      end


    end # class WithinValidator

    module ValidatesWithin
      ##
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
        validators.add(WithinValidator, *fields)
      end
    end # module ValidatesWithin
  end # module Validations
end # module DataMapper
