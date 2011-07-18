# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/format'

module DataMapper
  module Validation
    class Rule
      module Format

        class Proc < Rule

          include Format

          EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :format

          equalize *EQUALIZE_ON


          def valid?(resource)
            value = resource.validation_property_value(attribute_name)
            return true if optional?(value)

            self.format.call(value)
          # rescue ::Encoding::CompatibilityError
          #   # This is to work around a bug in jruby - see formats/email.rb
          #   false
          end

        end # class Proc

      end # module Format
    end # class Rule
  end # module Validation
end # module DataMapper
