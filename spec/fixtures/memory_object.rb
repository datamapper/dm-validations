# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__),'integer_dumped_as_string_property')

module DataMapper
  module Validation
    module Fixtures
      class MemoryObject
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,     Serial
        property :marked, Boolean, :auto_validation => false
        property :color,  String,  :auto_validation => false

        property :stupid_integer, IntegerDumpedAsStringProperty, :auto_validation => false

        #
        # Validations
        #

        validates_primitive_type_of :marked
        validates_primitive_type_of :color
        validates_primitive_type_of :stupid_integer
      end
    end
  end
end
