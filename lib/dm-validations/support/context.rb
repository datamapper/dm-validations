module DataMapper
  module Validations
    # Module with validation context functionality.
    #
    # Contexts are implemented using a thread-local array-based stack.
    #
    module Context

      # Execute a block of code within a specific validation context
      # 
      # @param [Symbol] context
      #   the context to execute the block of code within
      # 
      # @api semipublic
      def self.in_context(context)
        stack << context
        yield
      ensure
        stack.pop
      end

      # Get the current validation context or nil (if no context is on the stack).
      # 
      # @return [Symbol, NilClass]
      #   The current validation context (for the current thread),
      #   or nil if no current context is on the stack
      def self.current
        stack.last
      end

      # The (thread-local) validation context stack
      # This allows object graphs to be saved within potentially nested contexts
      # without having to pass the validation context throughout
      # 
      # @api semipublic
      def self.stack
        Thread.current[:dm_validations_context_stack] ||= []
      end

      # The default validation context for this Resource.
      # This Resource's default context can be overridden by implementing
      # #default_validation_context
      # 
      # @return [Symbol]
      #   the current validation context from the context stack
      #   (if valid for this model), or :default
      # 
      # @api semipublic
      def default_validation_context
        model.validators.current_context || :default
      end

    protected

      # Pushes given context on top of context stack and yields
      # given block, then pops the stack. During block execution
      # contexts previously pushed onto the stack have no effect.
      #
      # @api private
      # 
      # TODO: deprecate/remove
      def validation_context(context = default_validation_context)
        assert_valid_context(context)

        Validations::Context.in_context(context) { yield }
      end

    private

      # Initializes (if necessary) and returns current scope stack
      # @api private
      # 
      # TODO: deprecate/remove
      def validation_context_stack
        Validations::Context.stack
      end

      # Returns the current validation context or nil if none has been
      # pushed.
      #
      # @api private
      # 
      # TODO: deprecate/remove
      def current_validation_context
        model.validators.current_context
      end

      # Return the validation contexts for the resource
      #
      # @return [Hash]
      #   the hash of contexts for the resource
      #
      # @api private
      # 
      # TODO: deprecate/remove
      #   ContextualValidators#contexts (clear intent; method is on right object) vs
      #   Resource#contexts (unclear (too general); method is on wrong object)
      def contexts
        model.validators.contexts
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
      # TODO: deprecate/remove
      def valid_context?(context)
        model.validators.valid?(context)
      end

      # Assert that the context is valid for this model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @raise [InvalidContextError]
      #   raised if the context is not valid for this model
      #
      # @api private
      # 
      # TODO: deprecate/remove
      def assert_valid_context(context)
        model.validators.assert_valid(context)
      end

    end # module Context

    include Context
  end # module Validations
end # module DataMapper
