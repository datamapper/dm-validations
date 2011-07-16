# -*- encoding: utf-8 -*-

require 'forwardable'
require 'data_mapper/validations/context'
require 'data_mapper/validations/rule_set'

module DataMapper
  module Validations
    class ContextualRuleSet
      extend Forwardable
      include Enumerable

      # MessageTransformer to use for transforming Violations on Resources
      # instantiated from the model to which this ContextualRuleSet is bound
      # 
      # @api public
      attr_accessor :transformer

      # @api private
      attr_reader :rule_sets

      def_delegators :rule_sets, :each, :empty?

      # Clear all named context rule sets
      #
      # @api public
      def_delegators :rule_sets, :clear

      def initialize(model = nil)
        @model    = model
        @rule_sets = Hash.new do |h, context_name|
          h[context_name] = RuleSet.new(context_name)
        end
      end

      # Delegate #validate to RuleSet
      # 
      # @api public
      def validate(resource, context_name)
        context(context_name).validate(resource)
      end

      # Return the RuleSet for a given context name
      #
      # @param [String] name
      #   Context name for which to return a RuleSet
      # @return [RuleSet]
      #   RuleSet for the given context
      # 
      # @api public
      def context(name)
        rule_sets[name]
      end

      # Create a new rule of the given class for each name in +attribute_names+
      # and add the rules to the RuleSet(s) indicated
      # 
      # @param [DataMapper::Validations::Rule] rule_class
      #    Rule class, example: DataMapper::Validations::Rule::Presence
      #
      # @param [Array<Symbol>] attribute_names
      #    Attribute names given to validation macro, example:
      #    [:first_name, :last_name] in validates_presence_of :first_name, :last_name
      # 
      # @param [Hash] options
      #    Options supplied to validation macro, example:
      #    {:context=>:default, :maximum=>50, :allow_nil=>true, :message=>nil}
      # 
      # @option [Symbol] :context
      #   the context in which the new rule should be run
      # @option [Boolean] :allow_nil
      #   whether or not the new rule should allow nil values
      # @option [Boolean] :message
      #   the error message the new rule will provide on validation failure
      # 
      # @return [ContextualRuleSet]
      #   This method is a command, thus returns the receiver
      def add(rule_class, *attribute_names, &block)
        options  = attribute_names.last.kind_of?(Hash) ? attribute_names.pop.dup : {}
        contexts = extract_contexts(options)

        attribute_names.each do |attribute_name|
          rules = rule_class.rules_for(attribute_name, options, &block)

          contexts.each do |context|
            rules.each { |rule| self.context(context) << rule }

            # TODO: eliminate ModelExtensions#create_context_instance_methods,
            #   then eliminate the @model ivar entirely
            # In the meantime, update this method to return the context names
            #   to which rules were added, then override the Model methods
            #   in Macros to add these context shortcuts (as a deprecated shim)
            ContextualRuleSet.create_context_instance_methods(@model, context) if @model
          end
        end

        self
      end

      def inherited(descendant)
        rule_sets.each do |context_name, rule_set|
          rule_set.each do |rule|
            descendant.context(context_name) << rule.dup
          end
        end
      end


      def current_default_context
        current_context || :default
      end

      # Returns the current validation context on the stack if valid for this model,
      # nil if no contexts are defined for the model (and no contexts are on
      # the validation stack), or :default if the current context is invalid for
      # this model or no contexts have been defined for this model and
      # no context is on the stack.
      #
      # @return [Symbol]
      #   the current validation context from the stack (if valid for this model),
      #   nil if no context is on the stack and no contexts are defined for this model,
      #   or :default if the context on the stack is invalid for this model or
      #   no context is on the stack and this model has at least one validation context
      # 
      # @api private
      # 
      # TODO: simplify the semantics of #current_context, #validate
      def current_context
        context = Validations::Context.current
        valid_context?(context) ? context : :default
      end

      # Test if the context is valid for the model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @return [Boolean]
      #   true if the context is valid for the model
      #
      # @api private
      # 
      # TODO: investigate removing the `contexts.empty?` test here.
      def valid_context?(context)
        rule_sets.empty? || rule_sets.include?(context)
      end

      # Assert that the given context is valid for this model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @raise [InvalidContextError]
      #   raised if the context is not valid for this model
      #
      # @api private
      # 
      # TODO: is this method actually needed?
      def assert_valid(context)
        unless valid_context?(context)
          raise InvalidContextError, "#{context} is an invalid context, known contexts are #{rule_sets.keys.inspect}"
        end
      end

    private

      # Allow :context to be aliased to :group, :on, & :when
      # 
      # @param [Hash] options
      #   the options from which +context+ is to be extracted
      # 
      # @return [Array(Symbol)]
      #   the context(s) from +options+
      # 
      # @api private
      def extract_contexts(options)
        context = [
          options.delete(:context),
          options.delete(:group),
          options.delete(:when),
          options.delete(:on)
        ].compact.first

        Array(context || :default)
      end

      # Given a new context create an instance method of
      # valid_for_<context>? which simply calls validate(context)
      # if it does not already exist
      #
      # @api private
      def self.create_context_instance_methods(model, context)
        # TODO: deprecate `valid_for_#{context}?`
        # what's wrong with requiring the caller to pass the context as an arg?
        #   eg, `validate(:context)`
        # these methods *are* handy for symbol-based callbacks,
        #   eg. `:if => :valid_for_context?`
        # but they're so trivial to add where needed that it's
        # overkill to do this for all contexts on all validated objects.
        context = context.to_sym

        name = "valid_for_#{context}?"
        present = model.respond_to?(:resource_method_defined) ? model.resource_method_defined?(name) : model.instance_methods.include?(name)
        unless present
          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}                         # def valid_for_signup?
              validate(#{context.inspect})      #   validate(:signup)
            end                                 # end
          RUBY
        end
      end

    end # class ContextualRuleSet
  end # module Validations
end # module DataMapper
