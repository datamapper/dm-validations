# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/within'

module DataMapper
  module Validations
    class Rule
      module Within

        module Range

          include Within

          attr_reader :range

          def self.rules_for(attribute_name, options)
            Array(new(attribute_name, options))
          end

          def self.new(attribute_name, options)
            super if Within::Range != self

            range = options.fetch(:range) { options.fetch(:set) }

            if range.first != -Infinity && range.last != Infinity
              Bounded.new(attribute_name, options)
            elsif range.first == -Infinity
              UnboundedBegin.new(attribute_name, options)
            elsif range.last == Infinity
              UnboundedEnd.new(attribute_name, options)
            end
          end

          def initialize(attribute_name, options={})
            @range = options.fetch(:range) { options.fetch(:set) }

            super(attribute_name, DataMapper::Ext::Hash.except(options, :range, :set))
          end

          def valid?(resource)
            value = resource.validation_property_value(attribute_name)

            optional?(value) || range.include?(value)
          end

        end # module Range

      end # module Within
    end # class Rule
  end # module Validations
end # module DataMapper

require 'data_mapper/validations/rule/within/range/bounded'
require 'data_mapper/validations/rule/within/range/unbounded_begin'
require 'data_mapper/validations/rule/within/range/unbounded_end'
