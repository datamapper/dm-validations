module DataMapper
  module Validations
    class ValidationErrors

      include Enumerable

      @@default_error_messages = {
        :absent                   => '%s must be absent',
        :inclusion                => '%s must be one of %s',
        :invalid                  => '%s has an invalid format',
        :confirmation             => '%s does not match the confirmation',
        :accepted                 => '%s is not accepted',
        :nil                      => '%s must not be nil',
        :blank                    => '%s must not be blank',
        :length_between           => '%s must be between %s and %s characters long',
        :too_long                 => '%s must be at most %s characters long',
        :too_short                => '%s must be at least %s characters long',
        :wrong_length             => '%s must be %s characters long',
        :taken                    => '%s is already taken',
        :not_a_number             => '%s must be a number',
        :not_an_integer           => '%s must be an integer',
        :greater_than             => '%s must be greater than %s',
        :greater_than_or_equal_to => '%s must be greater than or equal to %s',
        :equal_to                 => '%s must be equal to %s',
        :not_equal_to             => '%s must not be equal to %s',
        :less_than                => '%s must be less than %s',
        :less_than_or_equal_to    => '%s must be less than or equal to %s',
        :value_between            => '%s must be between %s and %s',
        :primitive                => '%s must be of type %s'
      }

      # Holds a hash with all the default error messages that can
      # be replaced by your own copy or localizations.
      # 
      # @api public
      def self.default_error_messages=(default_error_messages)
        @@default_error_messages = default_error_messages
      end

      # @api public
      def self.default_error_message(key, field, *values)
        field = DataMapper::Inflector.humanize(field)
        @@default_error_messages[key] % [field, *values].flatten
      end

      attr_reader :resource

      # TODO: merge in gix's Violation/MessageTransformer work
      # then replace OrderedHash with OrderedSet and remove OrderedHash entirely
      def initialize(resource)
        @resource = resource
        @errors   = DataMapper::Validations::OrderedHash.new { |h,k| h[k] = [] }
      end

      # Clear existing validation errors.
      # 
      # @api public
      def clear!
        errors.clear
      end

      # Add a validation error. Use the attribute_name :general if the errors
      # does not apply to a specific field of the Resource.
      #
      # @param [Symbol] attribute_name
      #   The name of the field that caused the error
      # @param [String] message
      #   The message to add
      # 
      # @api public
      def add(attribute_name, message)
        if message.respond_to?(:try_call)
          # DM resource
          message = if (resource.respond_to?(:model) &&
                        resource.model.respond_to?(:properties))
                      message.try_call(
                        resource,
                        resource.model.properties[attribute_name]
                      )
                    else
                      # pure Ruby object
                      message.try_call(resource)
                    end
        end

        (errors[attribute_name] ||= []) << message
      end

      # Collect all errors into a single list.
      # 
      # @api public
      def full_messages
        errors.inject([]) do |list, pair|
          list += pair.last
        end
      end

      # Return validation errors for a particular attribute_name.
      #
      # @param [Symbol] attribute_name
      #   The name of the field you want an error for.
      #
      # @return [Array<DataMapper::Validations::Error>]
      #   Array of validation errors or empty array, if there are no errors
      #   on given field
      # 
      # @api public
      def on(attribute_name)
        errors_for_field = errors[attribute_name]
        DataMapper::Ext.blank?(errors_for_field) ? nil : errors_for_field.uniq
      end

      # @api public
      def each
        errors.each_value do |v|
          yield(v) unless DataMapper::Ext.blank?(v)
        end
      end

      # @api public
      def empty?
        @errors.all? { |property_name, errors| errors.empty? }
      end

      def method_missing(meth, *args, &block)
        errors.send(meth, *args, &block)
      end

      def respond_to?(method)
        super || errors.respond_to?(method)
      end

      # @api public
      def [](property_name)
        if (property_errors = errors[property_name.to_sym])
          property_errors
        end
      end

    private

      def errors
        @errors
      end

    end # class ValidationErrors
  end # module Validations
end # module DataMapper
