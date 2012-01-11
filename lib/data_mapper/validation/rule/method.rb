# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule'

module DataMapper
  module Validation
    class Rule

      class Method < Rule

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :method

        equalize *EQUALIZE_ON

        attr_reader :method

        def initialize(attribute_name, options={})
          super

          @method          = options.fetch(:method, attribute_name)
          @violation_type  = options.fetch(:violation_type, :unsatisfied_condition)
        end

        def validate(resource)
          result, error_message = resource.__send__(method)

          if result
            nil
          else
            Violation.new(resource, error_message, self)
          end
        end

        def violation_type(resource)
          @violation_type
        end

      end # class Method

    end # class Rule
  end # module Validation
end # module DataMapper
