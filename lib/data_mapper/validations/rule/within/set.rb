# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/within'

module DataMapper
  module Validations
    class Rule
      module Within

        class Set < Rule

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

          def violation_type(resource)
            :inclusion
          end

          def violation_data(resource)
            [ set.to_a.join(', ') ]
          end

        end # class Set

      end # module Within
    end # class Rule
  end # module Validations
end # module DataMapper
