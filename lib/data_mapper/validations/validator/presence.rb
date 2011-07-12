# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    class Validator

      class Presence < Validator

        # Boolean property types are considered present if non-nil.
        # Other property types are considered present if non-blank.
        # Non-properties are considered present if non-blank.
        def valid?(resource)
          value = resource.validation_property_value(attribute_name)

          boolean_type?(resource) ? !value.nil? : !DataMapper::Ext.blank?(value)
        end

        def violation_type(resource)
          boolean_type?(resource) ? :nil : :blank
        end

        # Is the property a boolean property?
        #
        # @return [Boolean]
        #   Returns true for Boolean, ParanoidBoolean, TrueClass and other
        #   properties. Returns false for other property types or for
        #   non-properties.
        # 
        # @api private
        # 
        # TODO: break this into concreate trypes and move the property check
        # into #initialize. Will require adding model to signature of #initialize
        def boolean_type?(resource)
          property = get_resource_property(resource, attribute_name)

          property ? property.primitive == TrueClass : false
        end

      end # class Presence

    end # class Validator
  end # module Validations
end # module DataMapper
