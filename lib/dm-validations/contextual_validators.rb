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

        runnable_validators = context(named_context).select{ |validator| validator.execute?(target) }
        validators = runnable_validators.dup

        # By default we start the list with the full set of runnable validators.
        #
        # In the case of a new Resource or regular ruby class instance,
        # everything needs to be validated completely, and no eager-loading
        # logic should apply.
        #
        # In the case of a DM::Resource that isn't new, we optimize:
        #
        #   1. Eager-load all lazy, not-yet-loaded properties that need
        #      validation, all at once.
        #
        #   2. Limit run validators to
        #      - those applied to dirty attributes only,
        #      - those that should always run (presence/absence)
        #      - those that don't reference any real properties (field-less
        #        block validators, validations in virtual attributes)
        if target.kind_of?(DataMapper::Resource) && !target.new?
          attrs       = target.attributes.keys
          dirty_attrs = target.dirty_attributes.keys.map{ |p| p.name }
          validators  = runnable_validators.select{|v|
            !attrs.include?(v.field_name) || dirty_attrs.include?(v.field_name)
          }

          # Load all lazy, not-yet-loaded properties that need validation,
          # all at once.
          fields_to_load = validators.map{|v|
            target.class.properties[v.field_name]
          }.compact.select {|p|
            p.lazy? && !p.loaded?(target)
          }

          target.__send__(:eager_load, fields_to_load)

          # Finally include any validators that should always run or don't
          # reference any real properties (field-less block vaildators).
          validators |= runnable_validators.select do |v|
            [ MethodValidator, PresenceValidator, AbsenceValidator ].any? do |klass|
              v.kind_of?(klass)
            end
          end
        end

        validators.map { |validator| validator.call(target) }.all?
      end

    end # module ContextualValidators
  end # module Validations
end # module DataMapper
