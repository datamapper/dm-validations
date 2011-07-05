# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validators/numericalness'

module DataMapper
  module Validations
    module Validators
      module Numericalness

        class Integer < Validator

          include Numericalness

          def expected
            /\A[+-]?\d+\z/
          end

          def validate_numericalness(value)
            # XXX: workaround for jruby. This is needed because the jruby
            # compiler optimizes a bit too far with magic variables like $~.
            # the value.send line sends $~. Inserting this line makes sure the
            # jruby compiler does not optimise here.
            # see http://jira.codehaus.org/browse/JRUBY-3765
            $~ = nil if RUBY_PLATFORM[/java/]

            value_as_string(value) =~ expected
          rescue ArgumentError
            # TODO: figure out better solution for: can't compare String with Integer
            true
          end

          def error_message_args
            [ :not_an_integer, attribute_name, expected ]
          end

        end # class Equal

      end # module Numericalness
    end # module Validators
  end # module Validations
end # module DataMapper
