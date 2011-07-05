# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Acceptance < Validator

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :accept

        equalize *EQUALIZE_ON

        DEFAULT_ACCEPTED_VALUES = [ '1', 1, 'true', true, 't' ]

        attr_reader :accept

        def initialize(attribute_name, options = {})
          @accept = Array(options.fetch(:accept, DEFAULT_ACCEPTED_VALUES))

          super(attribute_name, DataMapper::Ext::Hash.except(options, :accept))

          allow_nil! unless defined?(@allow_nil)
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if exempt_value?(value)
          accept.include?(value)
        end

        def error_message_args
          [ :accepted, attribute_name ]
        end

      private

        def exempt_value?(value)
          allow_nil? && value.nil?
        end

      end # class Acceptance

    end # module Validators
  end # module Validations
end # module DataMapper
