# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      class Presence < Validator

        def call(resource)
          value    = resource.validation_property_value(attribute_name)
          property = get_resource_property(resource, attribute_name)
          return true if present?(value, property)

          error_message = self.custom_message || default_error(property)
          add_error(resource, error_message, attribute_name)

          false
        end

      protected

        # Boolean property types are considered present if non-nil.
        # Other property types are considered present if non-blank.
        # Non-properties are considered present if non-blank.
        def present?(value, property)
          boolean_type?(property) ? !value.nil? : !DataMapper::Ext.blank?(value)
        end

        def default_error(property)
          actual = boolean_type?(property) ? :nil : :blank
          ValidationErrors.default_error_message(actual, attribute_name)
        end

        # Is the property a boolean property?
        #
        # @return [Boolean]
        #   Returns true for Boolean, ParanoidBoolean, TrueClass and other
        #   properties. Returns false for other property types or for
        #   non-properties.
        def boolean_type?(property)
          property ? property.primitive == TrueClass : false
        end

      end # class Presence

    end # module Validators
  end # module Validations
end # module DataMapper
