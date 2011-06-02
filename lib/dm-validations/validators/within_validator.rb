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
      # Validate that value of a field if within a range/set
      #
      def validates_within(*fields)
        validators.add(WithinValidator, *fields)
      end
    end # module ValidatesWithin
  end # module Validations
end # module DataMapper
