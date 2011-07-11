# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    class Validator

      class Presence < Validator

        # Boolean property types are considered present if non-nil.
        # Other property types are considered present if non-blank.
        # Non-properties are considered present if non-blank.
        def call(resource)
          value    = resource.validation_property_value(attribute_name)
          property = get_resource_property(resource, attribute_name)
          boolean  = boolean_type?(property)

          return true if valid?(boolean, value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(*error_message_args(boolean))

          add_error(resource, error_message, attribute_name)

          false
        end

        def valid?(boolean, value)
          boolean ? !value.nil? : !DataMapper::Ext.blank?(value)
        end

        def error_message_args(boolean)
          boolean ? [ :nil, attribute_name ] : [ :blank, attribute_name ]
        end

        # Is the property a boolean property?
        #
        # @return [Boolean]
        #   Returns true for Boolean, ParanoidBoolean, TrueClass and other
        #   properties. Returns false for other property types or for
        #   non-properties.
        # 
        # @api private
        def boolean_type?(property)
          property ? property.primitive == TrueClass : false
        end

      end # class Presence

    end # class Validator
  end # module Validations
end # module DataMapper
