#require File.dirname(__FILE__) + '/formats/email'

require 'pathname'
require 'dm-validations/formats/email'
require 'dm-validations/formats/url'

module DataMapper
  module Validations
    class UnknownValidationFormat < ::ArgumentError; end

    # @author Guy van den Berg
    # @since  0.9
    class FormatValidator < GenericValidator

      FORMATS = {}

      include DataMapper::Validations::Format::Email
      include DataMapper::Validations::Format::Url

      def initialize(field_name, options = {})
        super

        set_optional_by_default
      end

      def call(target)
        return true if valid?(target)

        value = target.validation_property_value(field_name)

        error_message = (
          @options[:message] || ValidationErrors.default_error_message(
            :invalid, field_name
          )
        )

        add_error(
          target,
          error_message.try_call(humanized_field_name, value),
          field_name
        )
        false
      end

      private

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)

        validation = @options[:as] || @options[:with]

        if validation.is_a?(Symbol) && !FORMATS.has_key?(validation)
          raise("No such predefined format '#{validation}'")
        end

        validator = if validation.is_a?(Symbol)
                      FORMATS[validation][0]
                    else
                      validation
                    end

        case validator
          when Proc   then validator.call(value)
          when Regexp then value ? value.to_s =~ validator : false
          else
            raise(UnknownValidationFormat, "Can't determine how to validate #{target.class}##{field_name} with #{validator.inspect}")
        end
      rescue Encoding::CompatibilityError
        # This is to work around a bug in jruby - see formats/email.rb
        false
      end

    end # class FormatValidator

    module ValidatesFormat
      extend Deprecate

      # Validates that the attribute is in the specified format. You may
      # use the :as (or :with, it's an alias) option to specify the
      # pre-defined format that you want to validate against. You may also
      # specify your own format via a Proc or Regexp passed to the the :as
      # or :with options.
      #
      # @option [Boolean] :allow_nil (true)
      #   true or false.
      #
      # @option [Boolean] :allow_blank (true)
      #   true or false.
      #
      # @option [Format, Proc, Regexp] :as
      #   The pre-defined format, Proc or Regexp to validate against.
      #
      # @option [Format, Proc, Regexp] :with
      #   An alias for :as.
      #
      #   :email_address (format is specified in DataMapper::Validations::Format::Email - note that unicode emails will *not* be matched under MRI1.8.7)
      #   :url (format is specified in DataMapper::Validations::Format::Url)
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :email, String
      #     property :zip_code, String
      #
      #     validates_format_of :email, :as => :email_address
      #     validates_format_of :zip_code, :with => /^\d{5}$/
      #
      #     # a call to valid? will return false unless:
      #     # email is formatted like an email address
      #     # and
      #     # zip_code is a string of 5 digits
      #
      def validates_format_of(*fields)
        validators.add(FormatValidator, *fields)
      end

      deprecate :validates_format, :validates_format_of
    end # module ValidatesFormat
  end # module Validations
end # module DataMapper
