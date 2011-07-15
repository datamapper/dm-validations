# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Validator

      module Numericalness

        def self.included(validator)
          validator.class_eval do
            const_set(:EQUALIZE_ON, superclass::EQUALIZE_ON.dup << :expected)

            equalize *self::EQUALIZE_ON
          end
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

        attr_reader :expected

        def initialize(attribute_name, options)
          super

          @expected = options[:expected]
        end

        def valid?(resource)
          # TODO: is it even possible for expected to be nil?
          #   if so, return a dummy validator when expected is nil
          return true if expected.nil?

          value = resource.validation_property_value(attribute_name)

          optional?(value) || validate_numericalness(value)
        end

        def violation_data(resource)
          [ expected ]
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

      end # class Numericalness

    end # class Validator
  end # module Validations
end # module DataMapper

require 'data_mapper/validations/rule/numericalness/integer'
require 'data_mapper/validations/rule/numericalness/numeric'

require 'data_mapper/validations/rule/numericalness/equal'
require 'data_mapper/validations/rule/numericalness/greater_than'
require 'data_mapper/validations/rule/numericalness/greater_than_or_equal'
require 'data_mapper/validations/rule/numericalness/less_than'
require 'data_mapper/validations/rule/numericalness/less_than_or_equal'
require 'data_mapper/validations/rule/numericalness/not_equal'
