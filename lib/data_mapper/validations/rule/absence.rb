# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Rule

      class Absence < Rule

        def initialize(attribute_name, options = {})
          options = options.merge(:allow_nil => false, :allow_blank => false)
          super(attribute_name, options)
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          DataMapper::Ext.blank?(value)
        end

        def violation_type(resource)
          :absent
        end

      end # class Absence

    end # class Rule
  end # module Validations
end # module DataMapper
