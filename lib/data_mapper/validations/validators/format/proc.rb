# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/format'

module DataMapper
  module Validations
    module Validators
      module Format

        class Proc < Validator

          include Format

          EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :format

          equalize *EQUALIZE_ON


          def valid?(value)
            return true if optional?(value)

            self.format.call(value)
          # rescue ::Encoding::CompatibilityError
          #   # This is to work around a bug in jruby - see formats/email.rb
          #   false
          end

          def error_message_args
            [ :invalid, attribute_name ]
          end

        end # class Regexp

      end # module Format
    end # module Validators
  end # module Validations
end # module DataMapper
