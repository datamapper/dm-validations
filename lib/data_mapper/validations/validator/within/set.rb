# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator/within'

module DataMapper
  module Validations
    class Validator
      module Within

        class Set < Validator

          EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :set

          equalize *EQUALIZE_ON

          include Within

          attr_reader :set

          def initialize(attribute_name, options={})
            @set = options.fetch(:set, [])

            super(attribute_name, DataMapper::Ext::Hash.except(options, :set))
          end

          def valid?(resource)
            value = resource.validation_property_value(attribute_name)

            optional?(value) || set.include?(value)
          end

          def violation_type
            :inclusion
          end

          def violation_data
            [ set.to_a.join(', ') ]
          end

        end # class Set

      end # module Within
    end # class Validator
  end # module Validations
end # module DataMapper
