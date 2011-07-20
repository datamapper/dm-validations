module DataMapper
  module Validation

    # Alias for validate(:default)
    #
    # @api public
    def valid_for_default?
      # warn "#{self.class}#valid_for_default? is deprecated and will be removed in a future version (#{caller[0]})"
      valid?(:default)
    end

    class ValidationError < StandardError; end

    class ErrorSet
      extend Deprecate

      deprecate :clear!, :clear

      def self.default_error_message(violation_type, attribute_name, *violation_data)
        MessageTransformer::Default.error_message(violation_type, attribute_name, *violation_data)
      end
    end

    class ContextualRuleSet
      extend Deprecate

      deprecate :contexts,  :rule_sets
      deprecate :clear!,    :clear

      def execute(context_name, resource)
        # warn "#{self.class}#execute is deprecated. Use #{self.class}#validate instead."
        context(context_name).execute(resource)
      end

      # Given a new context create an instance method of
      # valid_for_<context>? which simply calls validate(context)
      # if it does not already exist
      #
      # @api private
      def self.create_context_instance_methods(model, context)
        name = "valid_for_#{context}?"
        present = model.respond_to?(:resource_method_defined) ? model.resource_method_defined?(name) : model.instance_methods.include?(name)
        unless present
          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}                   # def valid_for_signup?
              # warn "\#{self.class}##{name} is deprecated. Use #valid?(context_name) instead (\#{caller[0]})"
              valid?(:#{context})         #   valid?(:signup)
            end                           # end
          RUBY
        end
      end

    end

    class Rule
      extend Deprecate

      deprecate :field_name, :attribute_name

      def humanized_field_name
        # warn "#{self.class}#humanized_field_name is deprecated and will be removed in a future version (#{caller[0]})"
        DataMapper::Inflector.humanize(attribute_name)
      end

      # Call the validator. "call" is used so the operation is BoundMethod
      # and Block compatible. This must be implemented in all concrete
      # classes.
      #
      # @param [Object] resource
      #   The resource that the validator must be called against.
      #
      # @return [Boolean]
      #   true if valid, otherwise false.
      #
      def call(resource)
        # warn "#{self.class}#call is deprecated and will be removed in a future version (#{caller[0]})"
        return true if valid?(resource)

        error_message = self.custom_message ||
          MessageTransformer::Default.error_message(
            violation_type(resource),
            attribute_name,
            *violation_data(resource))

        add_error(resource, error_message, attribute_name)

        false
      end

      class Block
        def call(resource)
          # warn "#{self.class}#call is deprecated and will be removed in a future version (#{caller[0]})"
          result, error_message = resource.instance_eval(&self.block)
          add_error(resource, error_message, attribute_name) unless result
          result
        end
      end

      class Method
        def call(resource)
          # warn "#{self.class}#call is deprecated and will be removed in a future version (#{caller[0]})"
          result, error_message = resource.__send__(method)
          add_error(resource, error_message, attribute_name) unless result
          result
        end
      end

    end

    class RuleSet
      extend Deprecate

      # This is present to provide a backwards-compatible codepath to
      # ContextualRuleSet#execute
      def execute(resource)
        rules = rules_for_resource(resource)
        rules.map { |rule| rule.call(resource) }.all?
      end
    end

    class Violation
      # TODO: Extract the correct custom message for a Rule's context
      #   (in ContextualRuleSet#add). That change will break this interface.
      def [](context_name)
        # warn "Accessing custom messages by context name will be removed in a future version (#{caller[0]})"
        @custom_message[context_name]
      end
    end

    module Macros
      extend Deprecate

      deprecate :validates_absent,        :validates_absence_of
      deprecate :validates_format,        :validates_format_of
      deprecate :validates_present,       :validates_presence_of
      deprecate :validates_length,        :validates_length_of
      deprecate :validates_is_accepted,   :validates_acceptance_of
      deprecate :validates_is_confirmed,  :validates_confirmation_of
      deprecate :validates_is_number,     :validates_numericality_of
      deprecate :validates_is_primitive,  :validates_primitive_type_of
      deprecate :validates_is_unique,     :validates_uniqueness_of

      def validates_numericality_of(*attribute_names)
        # warn "'Numericality' is not a word in the English language, please use validates_numericalness_of (#{caller[0]})"
        options = attribute_names.last.kind_of?(Hash) ? attribute_names.pop : {}
        validators.add(Rule::Numericalness, attribute_names, options)
      end
    end

    module Inferred
      extend Deprecate

      # TODO: why are there 3 entry points to this ivar?
      # #disable_auto_validations, #disabled_auto_validations?, #auto_validations_disabled?
      # def disable_auto_validations
      #   !infer_validations?
      # end

      # Checks whether auto validations are currently
      # disabled (see +disable_auto_validations+ method
      # that takes a block)
      #
      # @return [TrueClass, FalseClass]
      #   true if auto validation is currently disabled
      #
      # @api semipublic
      # def disabled_auto_validations?
      #   !infer_validations?
      # end

      # deprecate :auto_validations_disabled?,  :infer_validations?
      # deprecate :without_auto_validations,    :without_inferred_validations

    end # module Inferred

    AutoValidations = Inferred
    ContextualValidators = ContextualRuleSet
    ValidationErrors = ErrorSet

  end # module Validation

  # Previous top-level namespace (1.0-1.1)
  Validations = Validation
  # Very old constant name (0.9?)
  Validate    = Validation

end # module DataMapper
