require 'data_mapper/validations/error_set'
require 'data_mapper/validations/contextual_rule_set'
require 'data_mapper/validations/macros'

module DataMapper
  module Validations

    def self.included(base)
      base.extend ClassMethods
    end

    # Check if a resource is valid in a given context
    #
    # @api public
    def valid?(context_name = default_validation_context)
      validate(context_name).errors.empty?
    end

    # Command a resource to populate its ErrorSet with any violations of
    # its validation Rules in +context_name+
    #
    # @api public
    def validate(context_name = default_validation_context)
      errors.clear
      validation_violations(context_name).each { |v| errors.add(v) }

      self
    end

    # Get a list of violations for the receiver *without* mutating it
    # 
    # @api private
    def validation_violations(context_name = default_validation_context)
      self.class.validators.validate(self, context_name)
    end

    # @return [ErrorSet]
    #   the collection of current validation errors for this resource
    #
    # @api public
    def errors
      @errors ||= ErrorSet.new(self)
    end

    # @api public
    # The default validation context for this Resource.
    # This Resource's default context can be overridden by implementing
    # #default_validation_context
    # 
    # @return [Symbol]
    #   the current validation context from the context stack
    #   (if valid for this model), or :default
    # 
    # @api public
    def default_validation_context
      self.class.validators.current_context
    end

    def validation_property_value(name)
      __send__(name) if respond_to?(name, true)
    end

    # Mark this resource as validatable. When we validate associations of a
    # resource we can check if they respond to validatable? before trying to
    # recursively validate them
    #
    # @api public
    def validatable?
      true
    end

    module ClassMethods

      include Validations::Macros

      # Return the set of contextual validators or create a new one
      #
      # @api public
      def validators
        @validators ||= ContextualRuleSet.new(self)
      end

      # @api private
      def inherited(base)
        super
        self.validators.inherited(base.validators)
      end

    end # module ClassMethods

  end # module Validations
end # module DataMapper
