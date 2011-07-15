# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/format'

module DataMapper
  module Validations
    class Validator
      module Format

        class Proc < Validator

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

          def violation_type(resource)
            :invalid
          end

        end # class Regexp

      end # module Format
    end # class Validator
  end # module Validations
end # module DataMapper
