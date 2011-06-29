# -*- encoding: utf-8 -*-

require 'forwardable'

require 'data_mapper/validations/validation_context'

module DataMapper
  module Validations
    #
    # @author Guy van den Berg
    # @since  0.9

    class ContextualValidators
      extend Forwardable
      include Enumerable

      def_delegators :contexts, :each, :empty?

      attr_reader :contexts

      def initialize(model = nil)
        @model    = model
        @contexts = Hash.new { |h,k| h[k] = ValidationContext.new }
      end

      # Return an array of validators for a named context
      #
      # @param  [String]
      #   Context name for which to return validators
      # @return [Array<Validations::Validators::Abstract>]
      #   An array of validators bound to the given context
      def context(name)
        contexts[name]
      end

      # Clear all named context validators off of the resource
      #
      # @api public
      def clear!
        contexts.clear
      end

      # Create a new validator of the given klazz and push it onto the
      # requested context for each of the attribute_names in +attribute_names+
      # 
      # @param [DataMapper::Validations::GenericValidator] validator_class
      #    Validator class, example: DataMapper::Validations::LengthValidator
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
      #   the context in which the new validator should be run
      # @option [Boolean] :allow_nil
      #   whether or not the new validator should allow nil values
      # @option [Boolean] :message
      #   the error message the new validator will provide on validation failure
      def add(validator_class, *attribute_names)
        options  = attribute_names.last.kind_of?(Hash) ? attribute_names.pop.dup : {}
        contexts = extract_contexts(options)

        attribute_names.each do |attribute_name|
          validator = validator_class.new(attribute_name, options)

          self.attribute(attribute_name) << validator

          contexts.each do |context|
            self.context(context) << validator

            # TODO: eliminate ModelExtensions#create_context_instance_methods,
            #   then eliminate the @model ivar entirely
            # In the meantime, update this method to return the context names
            #   to which validators were added, then override the Model methods
            #   in Validators to add these context shortcuts (as a deprecated shim)
            ModelExtensions.create_context_instance_methods(@model, context) if @model
          end
        end
      end

      def inherited(descendant_validators)
        contexts.each do |context, validators|
          validators.each do |v|
            # TODO: move :context arg out of the options hash
            options = v.options.merge(:context => context)
            descendant_validators.add(v.class, v.field_name, options)
          end
        end
      end

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
          options.delete(:group),
          options.delete(:on),
          options.delete(:when),
          options.delete(:context)
        ].compact.first

        Array(context || :default)
      end

      # Delegate #validate to ValidationContext
      # 
      # @api public
      def validate(context_name, resource)
        context(context_name).validate(resource)
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
        contexts.empty? || contexts.include?(context)
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
          raise InvalidContextError, "#{context} is an invalid context, known contexts are #{contexts.keys.inspect}"
        end
      end


      module ModelExtensions
        # Return the set of contextual validators or create a new one
        #
        # @api public
        def validators
          @validators ||= ContextualValidators.new(self)
        end

        # @api private
        def inherited(base)
          super
          self.validators.inherited(base.validators)
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

      end # module ModelExtensions
    end # class ContextualValidators
  end # module Validations

  Model.append_extensions Validations::ContextualValidators::ModelExtensions

end # module DataMapper
