require 'forwardable'

module DataMapper
  module Validations

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class ContextualValidators
      extend Forwardable

      #
      # Delegators
      #

      def_delegators :@contexts, :empty?, :each
      include Enumerable

      attr_reader :contexts

      def initialize
        @contexts = {}
      end

      #
      # API
      #

      # Return an array of validators for a named context
      #
      # @param  [String]
      #   Context name for which return validators
      # @return [Array<DataMapper::Validations::GenericValidator>]
      #   An array of validators
      def context(name)
        contexts[name] ||= []
      end

      # Clear all named context validators off of the resource
      #
      def clear!
        contexts.clear
      end

      # Execute all validators in the named context against the target.  Load
      # together any properties that are designated lazy but are not yet loaded.
      # Optionally only validate dirty properties.
      #
      # @param [Symbol]
      #   named_context the context we are validating against
      # @param [Object]
      #   target        the resource that we are validating
      # @return [Boolean]
      #   true if all are valid, otherwise false
      def execute(named_context, target)
        target.errors.clear!

        validators = context(named_context).select { |validator| validator.execute?(target) }

        # Only run validators on dirty attributes.
        validators = validators.select{|v| target.dirty_attributes.keys.include?(v.field_name) }

        # Load all lazy, not-yet-loaded, needs-to-be-validated properties.
        need_to_load = validators.map{ |v| target.class.properties[v.field_name] }.select { |p| p.lazy? && !p.loaded?(target) }
        target.__send__(:eager_load, need_to_load)

        validators.map { |validator| validator.call(target) }.all?
      end

    end # module ContextualValidators
  end # module Validations
end # module DataMapper
