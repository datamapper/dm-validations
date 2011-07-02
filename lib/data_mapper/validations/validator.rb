# -*- encoding: utf-8 -*-

module DataMapper
  module Validations
    # TODO: rewrite this. specifically, validation logic should not
    # be intertwined with message generation.
    # Also, supporting multiple validation types per validator is too complicated
    class Validator
      extend Equalizer

      EQUALIZE_ON = [:attribute_name, :custom_message, :if_clause, :unless_clause, :options]
      equalize *EQUALIZE_ON

      # @api private
      attr_reader :attribute_name

      # @api private
      attr_reader :custom_message

      # @api private
      attr_reader :if_clause

      # @api private
      attr_reader :unless_clause

      # TODO: remove :field_name alias
      alias_method :field_name, :attribute_name

      # @api private
      attr_reader :options

      # Get the validators for the given attribute_name and options
      # 
      # @param [Symbol] attribute_name
      #   the name of the attribute to which the returned validators will be bound
      # @param [Hash] options
      #   the options with which to configure the returned validators
      # 
      # @return [#each(Validator)]
      #   a collection of validators which collectively
      # 
      def self.validators_for(attribute_name, options, &block)
        Array(new(attribute_name, options, &block))
      end

      # Construct a validator. Capture the :if and :unless clauses when
      # present.
      #
      # @param [String, Symbol] attribute_name
      #   The name of the attribute to validate.
      #
      # @option [Symbol, Proc] :if
      #   The name of a method or a Proc to call to determine if the
      #   validation should occur.
      #
      # @option [Symbol, Proc] :unless
      #   The name of a method or a Proc to call to determine if the
      #   validation should not occur.
      #
      # @note
      #   All additional key/value pairs are passed through to the validator
      #   that is sub-classing this GenericValidator
      #
      def initialize(attribute_name, options = {})
        @attribute_name = attribute_name
        @options        = DataMapper::Ext::Hash.except(options, :if, :unless)
        @custom_message = options[:message]
        @if_clause      = options[:if]
        @unless_clause  = options[:unless]
      end

      def humanized_field_name
        DataMapper::Inflector.humanize(attribute_name)
      end

      # Add an error message to a resource. If the error corresponds to
      # a specific attribute name of the resource, add it to the errors for that
      # attribute name, otherwise add it under the :general attribute name
      #
      # @param [Object] resource
      #   The resource that has the error.
      # @param [String] message
      #   The message to add.
      # @param [Symbol] attribute_name
      #   The name of the field that caused the error.
      #
      # @return [Validator]
      #   The receiver (self)
      def add_error(resource, message, attribute_name = :general)
        # TODO: should the attribute_name for a general message be :default???
        resource.errors.add(attribute_name, message)
        self
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
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      # Determines if this validator should be run against the
      # resource by evaluating the :if and :unless clauses
      # optionally passed while specifying any validator.
      #
      # @param [Object] resource
      #   The resource that we check against.
      #
      # @return [Boolean]
      #   true if should be run, otherwise false.
      #
      # @api private
      def execute?(resource)
        if unless_clause = self.unless_clause
          !evaluate_conditional_clause(resource, unless_clause)
        elsif if_clause = self.if_clause
          evaluate_conditional_clause(resource, if_clause)
        else
          true
        end
      end

      # @api private
      def evaluate_conditional_clause(resource, clause)
        if clause.kind_of?(Symbol)
          resource.__send__(clause)
        elsif clause.respond_to?(:call)
          clause.call(resource)
        end
      end

      # Set the default value for allow_nil and allow_blank
      #
      # @param [Boolean] default value
      #
      # @api private
      def set_optional_by_default(default = true)
        [ :allow_nil, :allow_blank ].each do |key|
          @options[key] = true unless options.key?(key)
        end
      end

      # Test the value to see if it is blank or nil, and if it is allowed.
      # Note that allowing blank without explicitly denying nil allows nil
      # values, since nil.blank? is true.
      #
      # @param [Object] value
      #   The value to test.
      #
      # @return [Boolean]
      #   true if blank/nil is allowed, and the value is blank/nil.
      #
      # @api private
      def optional?(value)
        if value.nil?
          options.fetch(:allow_nil) { options.fetch(:allow_blank, false) }
        elsif DataMapper::Ext.blank?(value)
          options.fetch(:allow_blank, false)
        end
      end

      def inspect
        out = "#<#{self.class.name}"
        # out << "@attribute_name=#{attribute_name.inspect} "
        # out << "@if_clause=#{if_clause.inspect} "         if if_clause
        # out << "@unless_clause=#{unless_clause.inspect} " if unless_clause
        # out << "@options=#{options.inspect}>"
        self.class::EQUALIZE_ON.each do |ivar|
          value = send(ivar)
          out << " @#{ivar}=#{value.inspect}" if value
        end
        out << ">"
      end

      alias_method :to_s, :inspect

    private

      # Get the corresponding Resource property, if it exists.
      #
      # Note: DataMapper validations can be used on non-DataMapper resources.
      # In such cases, the return value will be nil.
      # 
      # @api private
      def get_resource_property(resource, property_name)
        model = resource.model if resource.respond_to?(:model)
        repository = resource.repository               if model
        properties = model.properties(repository.name) if model
        properties[property_name]                      if properties
      end

    end # class Validator
  end # module Validations
end # module DataMapper
