module DataMapper
  module Validation
    # Transforms Violations to error message strings.
    #
    # @abstract
    #   Subclass and override {#transform} to implement a custom message
    #   transformer. Use {Violation.message_transformer=} to set a new
    #   message transformer or pass the transformer to {Violation#message}.
    class MessageTransformer

      # Transforms the specified Violation to an error message string.
      #
      # @param [Violation] violation
      #   The Violation to transform.
      # 
      # @return [String]
      #   The transformed message.
      #
      # @raise [ArgumentError]
      #   +violation+ is +nil+.
      def transform(violation)
        raise NotImplementedError, "#{self.class}#transform must be implemented"
      end


      class Default < self
        @error_messages = {
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

        class << self
          # Gets the hash of error messages used to transform violations.
          #
          # @return [Hash{Symbol=>String}]
          attr_reader :error_messages
        end

        # Merges the specified +error_messages+ hash into the internal hash of
        # error messages.
        #
        # @param [Hash{Symbol=>String}] error_messages
        #   The error messages to be merged.
        def self.error_messages=(error_messages)
          unless error_messages.is_a?(Hash)
            raise ArgumentError, "+error_messages+ must be a hash" 
          end

          self.error_messages.merge!(error_messages)
        end

        def self.error_message(violation_type, attribute_name, violation_values)
          if message = self.error_messages[violation_type]
            attribute_name = DataMapper::Inflector.humanize(attribute_name)
            message % [attribute_name, *violation_values].flatten
          else
            violation_type.to_s
          end
        end

        def transform(violation)
          raise ArgumentError, "+violation+ must be specified" if violation.nil?

          attribute_name = violation.attribute_name

          self.class.error_message(violation.type, attribute_name, violation.values)
        end
      end # class Default

      class DefaultI18n < self
        def transform(violation)
          raise ArgumentError, "+violation+ must be specified" if violation.nil?

          resource       = violation.resource
          model_name     = resource.model.model_name
          attribute_name = violation.attribute_name

          options = {
            :model     => ::I18n.translate("models.#{model_name}"),
            :attribute => ::I18n.translate("attributes.#{model_name}.#{attribute_name}"),
            :value     => resource.validation_property_value(attribute_name)
          }.merge(violation.info)

          ::I18n.translate("errors.#{violation.type}", options)
        end
      end # class I18n

    end # class MessageTransformer

  end # module Validation
end # module DataMapper
