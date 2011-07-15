# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

require 'data_mapper/validations/rule/formats/email'
require 'data_mapper/validations/rule/formats/url'

module DataMapper
  module Validations
    class UnknownValidationFormat < ::ArgumentError; end

    class Rule

      module Format

        FORMATS = {
          :email_address => Formats::EmailAddress,
          :url           => Formats::Url
        }
        # TODO: evaluate re-implementing custom error messages per format type
        # previously these strings were wrapped in lambdas, which were, at one
        # point, invoked with #try_call with the humanized attribute name and value
        FORMAT_MESSAGES = {
          :email_address => '%s is not a valid email address',
          :url           => '%s is not a valid URL',
        }


        def self.validators_for(attribute_name, options)
          Array(new(attribute_name, options))
        end

        # @raise [UnknownValidationFormat]
        #   if the :as (or :with) option is a Symbol that is not a key in FORMATS,
        #   or if the provided format is not a Regexp, Symbol or Proc
        def self.new(attribute_name, options)
          format = options.delete(:as) || options.delete(:with)

          case format
          when Symbol
            regexp = FORMATS.fetch(format) do
              raise UnknownValidationFormat, "No such predefined format '#{format}'"
            end
            self::Regexp.new(attribute_name, options.merge(:format => regexp, :format_name => format))
          when ::Regexp
            self::Regexp.new(attribute_name, options.merge(:format => format))
          when ::Proc
            self::Proc.new(attribute_name, options.merge(:format => format))
          else
            raise UnknownValidationFormat, "Expected a Regexp, Symbol, or Proc format. Got: #{format.inspect}"
          end
        end


        attr_reader :format

        def initialize(attribute_name, options)
          @format = options[:format]

          super(attribute_name, DataMapper::Ext::Hash.except(options, :format))

          allow_nil!   unless defined?(@allow_nil)
          allow_blank! unless defined?(@allow_blank)
        end

        def violation_type(resource)
          :invalid
        end

        # TODO: integrate format into error message key?
        # def error_message_args
        #   if format.is_a?(Symbol)
        #     [ :"invalid_#{format}", attribute_name ]
        #   else
        #     [ :invalid, attribute_name ]
        #   end
        # end

      end # class Format

    end # class Rule
  end # module Validations
end # module DataMapper

require 'data_mapper/validations/rule/format/proc'
require 'data_mapper/validations/rule/format/regexp'
