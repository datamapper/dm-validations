module DataMapper
  module Validations
    # @author Martin Kihlgren
    # @since  0.9
    class AcceptanceValidator < GenericValidator

      def initialize(field_name, options = {})
        super

        @options[:allow_nil] = true unless @options.key?(:allow_nil)

        @options[:accept] ||= [ '1', 1, 'true', true, 't' ]
        @options[:accept] = Array(@options[:accept])
      end

      def call(target)
        return true if valid?(target)

        error_message = (
          @options[:message] || ValidationErrors.default_error_message(
            :accepted, field_name
          )
        )
        add_error(target, error_message, field_name)

        false
      end

      private

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if allow_nil?(value)
        @options[:accept].include?(value)
      end

      def allow_nil?(value)
        @options[:allow_nil] && value.nil?
      end

    end # class AcceptanceValidator

    module ValidatesAcceptance
      extend Deprecate

      # Validates that the attributes's value is in the set of accepted
      # values.
      #
      # @option [Boolean] :allow_nil (true)
      #   true if nil is allowed, false if not allowed.
      #
      # @option [Array] :accept (["1", 1, "true", true, "t"])
      #   A list of accepted values.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :license_agreement_accepted, String
      #     property :terms_accepted, String
      #     validates_acceptance_of :license_agreement, :accept => "1"
      #     validates_acceptance_of :terms_accepted, :allow_nil => false
      #
      #     # a call to valid? will return false unless:
      #     # license_agreement is nil or "1"
      #     # and
      #     # terms_accepted is one of ["1", 1, "true", true, "t"]
      #
      def validates_acceptance_of(*fields)
        validators.add(AcceptanceValidator, *fields)
      end

      deprecate :validates_is_accepted, :validates_acceptance_of

    end # module ValidatesIsAccepted
  end # module Validations
end # module DataMapper
