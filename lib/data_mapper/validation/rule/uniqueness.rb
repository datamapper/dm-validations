# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule'

module DataMapper
  module Validation
    class Rule
      class Uniqueness < Rule

        include DataMapper::Assertions

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :scope

        equalize *EQUALIZE_ON

        attr_reader :scope

        def initialize(attribute_name, options = {})
          if options.include?(:scope)
            assert_kind_of('scope', options[:scope], Array, Symbol)
          end

          super

          @scope = Array(options.fetch(:scope, nil))

          allow_nil!   unless defined?(@allow_nil)
          allow_blank! unless defined?(@allow_blank)
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if optional?(value)

          opts = {
            :fields        => resource.model.key(resource.repository.name),
            attribute_name => value,
          }

          scope.each { |subject|
            unless resource.respond_to?(subject)
              raise(ArgumentError,"Could not find property to scope by: #{subject}. Note that :unique does not currently support arbitrarily named groups, for that you should use :unique_index with an explicit validates_uniqueness_of.")
            end

            opts[subject] = resource.__send__(subject)
          }

          other_resource = DataMapper.repository(resource.repository.name) do
            resource.model.first(opts)
          end

          return true if other_resource.nil?
          resource.saved? && other_resource.key == resource.key
        end

        def violation_type(resource)
          :taken
        end

      end # class Uniqueness
    end # class Rule
  end # module Validation
end # module DataMapper
