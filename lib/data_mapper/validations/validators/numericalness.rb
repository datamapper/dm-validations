# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators

      module Numericalness

        attr_reader :expected

        # TODO: DRY this up (also implemented in Validator)
        def self.validators_for(attribute_name, options)
          Array(new(attribute_name, options))
        end

        # TODO: move options normalization into the validator macros?
        def self.validators_for(attribute_name, options)
          options = options.dup

          int = scour_options_of_keys(options, [:only_integer, :integer_only])

          gt  = scour_options_of_keys(options, [:gt,  :greater_than])
          lt  = scour_options_of_keys(options, [:lt,  :less_than])
          gte = scour_options_of_keys(options, [:gte, :greater_than_or_equal_to])
          lte = scour_options_of_keys(options, [:lte, :less_than_or_equal_to])
          eq  = scour_options_of_keys(options, [:eq,  :equal, :equals, :exactly, :equal_to])
          ne  = scour_options_of_keys(options, [:ne,  :not_equal_to])

          validators = []
          validators << Integer.new(attribute_name, options)                                    if int
          validators << Numeric.new(attribute_name, options)                                    if !int
          validators << GreaterThan.new(attribute_name, options.merge(:expected => gt))         if gt
          validators << LessThan.new(attribute_name, options.merge(:expected => lt))            if lt
          validators << GreaterThanOrEqual.new(attribute_name, options.merge(:expected => gte)) if gte
          validators << LessThanOrEqual.new(attribute_name, options.merge(:expected => lte))    if lte
          validators << Equal.new(attribute_name, options.merge(:expected => eq))               if eq
          validators << NotEqual.new(attribute_name, options.merge(:expected => ne))            if ne
          validators
        end

        def self.scour_options_of_keys(options, keys)
          keys.map { |key| options.delete(key) }.compact.first
        end

        def initialize(attribute_name, options)
          super
          @expected = options[:expected]
        end

        def call(target)
          # TODO: return a dummy validator is expected is nil
          return true if expected.nil?

          value = target.validation_property_value(attribute_name)
          return true if optional?(value)

          return true unless failed = validate_numericalness(value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(
              error_message_name,
              attribute_name,
              expected)
          add_error(target, error_message, attribute_name)
          false
        end

      private

        def value_as_string(value)
          case value
            # Avoid Scientific Notation in Float to_s
            when Float      then value.to_d.to_s('F')
            when BigDecimal then value.to_s('F')
            else value.to_s
          end
        end

        def validate_with_comparison(value, negated = false)
          # XXX: workaround for jruby. This is needed because the jruby
          # compiler optimizes a bit too far with magic variables like $~.
          # the value.send line sends $~. Inserting this line makes sure the
          # jruby compiler does not optimise here.
          # see http://jira.codehaus.org/browse/JRUBY-3765
          $~ = nil if RUBY_PLATFORM[/java/]

          comparison_boolean = value.send(comparison, expected)
          return if negated ? !comparison_boolean : comparison_boolean
          true
        rescue ArgumentError
          # TODO: figure out better solution for: can't compare String with Integer
          false
        end

      end # class Numericalness

    end # module Validators
  end # module Validations
end # module DataMapper

require 'data_mapper/validations/validators/numericalness/integer'
require 'data_mapper/validations/validators/numericalness/numeric'

require 'data_mapper/validations/validators/numericalness/equal'
require 'data_mapper/validations/validators/numericalness/greater_than'
require 'data_mapper/validations/validators/numericalness/greater_than_or_equal'
require 'data_mapper/validations/validators/numericalness/less_than'
require 'data_mapper/validations/validators/numericalness/less_than_or_equal'
require 'data_mapper/validations/validators/numericalness/not_equal'
