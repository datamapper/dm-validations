# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/numericalness'

module DataMapper
  module Validation
    class Rule
      module Numericalness

        class Integer < Rule

          include Numericalness

          def expected
            /\A[+-]?\d+\z/
          end

          def valid_numericalness?(value)
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

          def violation_type(resource)
            :not_an_integer
          end

        end # class Equal

      end # module Numericalness
    end # class Rule
  end # module Validation
end # module DataMapper
