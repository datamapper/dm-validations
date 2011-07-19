# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule/numericalness'

module DataMapper
  module Validation
    class Rule
      module Numericalness

        class Numeric < Rule

          include Numericalness

          attr_reader :precision
          attr_reader :scale

          def initialize(attribute_name, options)
            super

            @precision = options.fetch(:precision, nil)
            @scale     = options.fetch(:scale,     nil)

            unless expected # validate precision and scale attrs
              raise ArgumentError, "Invalid precision #{precision.inspect} and scale #{scale.inspect} for #{attribute_name}"
            end
          end

          def expected(precision = @precision, scale = @scale)
            if precision && scale
              if precision > scale && scale == 0
                /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
              elsif precision > scale
                delta = precision - scale
                /\A[+-]?(?:\d{1,#{delta}}|\d{0,#{delta}}\.\d{1,#{scale}})\z/
              elsif precision == scale
                /\A[+-]?(?:0(?:\.\d{1,#{scale}})?)\z/
              else
                nil
              end
            else
              /\A[+-]?(?:\d+|\d*\.\d+)\z/
            end
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
            :not_a_number
          end

        end # class Numeric

      end # module Numericalness
    end # class Rule
  end # module Validation
end # module DataMapper
