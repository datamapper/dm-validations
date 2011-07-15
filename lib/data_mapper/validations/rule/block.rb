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

        def call(resource)
          result, error_message = resource.instance_eval(&self.block)
          add_error(resource, error_message, attribute_name) unless result
          result
        end

      end # class Block

    end # class Rule
  end # module Validations
end # module DataMapper
