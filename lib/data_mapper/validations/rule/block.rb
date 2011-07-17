# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Rule

      class Block < Rule

        attr_reader :block

        def initialize(attribute_name, options, &block)
          super

          unless block_given?
            raise ArgumentError, 'cannot initialize a Block validator without a block'
          end

          @block = block
        end

        def validate(resource)
          result, error_message = resource.instance_eval(&self.block)

          if result
            nil
          else
            Violation.new(resource, error_message, self)
          end
        end

      end # class Block

    end # class Rule
  end # module Validations
end # module DataMapper
