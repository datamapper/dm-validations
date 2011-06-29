module DataMapper
  module Validations

    def self.included(model)
      model.extend ClassMethods
    end

    # Ensures the object is valid for the context provided, and otherwise
    # throws :halt and returns false.
    #
    # @api public
    def save(context = default_validation_context)
      model.validators.assert_valid(context)
      Context.in_context(context) { super() }
    end

    # @api public
    def update(attributes = {}, context = default_validation_context)
      model.validators.assert_valid(context)
      Context.in_context(context) { super(attributes) }
    end

    # @api private
    def save_self(*)
      if dirty_self? && Context.any? && !validate(model.validators.current_context)
        false
      else
        super
      end
    end

    # Return the ValidationErrors
    #
    # @api public
    def errors
      @errors ||= ValidationErrors.new(self)
    end

    # Mark this resource as validatable. When we validate associations of a
    # resource we can check if they respond to validatable? before trying to
    # recursively validate them
    #
    # @api semipublic
    def validatable?
      true
    end

    # Check if a resource is valid in a given context
    #
    # @api public
    def validate(context = :default)
      model = respond_to?(:model) ? self.model : self.class
      validation_context = model.validators.context(context)
      validation_context.validate(self)
    end

    alias_method :valid?, :validate

    # Alias for valid?(:default)
    #
    # TODO: deprecate
    # 
    # @api public
    def valid_for_default?
      valid?(:default)
    end

    # @api public
    def validation_property_value(name)
      __send__(name) if respond_to?(name, true)
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


    module ClassMethods
      # @api public
      def create(attributes = {}, *args)
        resource = new(attributes)
        resource.save(*args)
        resource
      end
    end # module ClassMethods
  end # module Validations

  # Provide a const alias for backward compatibility with plugins
  # This is scheduled to go away though, definitely before 1.0
  Validate = Validations

  Model.append_inclusions Validations

end
