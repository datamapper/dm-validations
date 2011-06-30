# -*- encoding: utf-8 -*-

module DataMapper
  module Validations
    class Validator
      # @api private
      attr_reader :if_clause

      # @api private
      attr_reader :unless_clause

      # @api private
      attr_reader :attribute_name

      # TODO: remove :field_name alias
      alias_method :field_name, :attribute_name

      # @api private
      attr_reader :options

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
        @if_clause      = options[:if]
        @unless_clause  = options[:unless]
      end

      def humanized_field_name
        DataMapper::Inflector.humanize(attribute_name)
      end

      # Add an error message to a target resource. If the error corresponds to
      # a specific attribute name of the resource, add it to the errors for that
      # attribute name, otherwise add it under the :general attribute name
      #
      # @param [Object] target
      #   The resource that has the error.
      # @param [String] message
      #   The message to add.
      # @param [Symbol] attribute_name
      #   The name of the field that caused the error.
      #
      # @return [Validator]
      #   The receiver (self)
      def add_error(target, message, attribute_name = :general)
        # TODO: should the attribute_name for a general message be :default???
        target.errors.add(attribute_name, message)
        self
      end

      # Call the validator. "call" is used so the operation is BoundMethod
      # and Block compatible. This must be implemented in all concrete
      # classes.
      #
      # @param [Object] target
      #   The resource that the validator must be called against.
      #
      # @return [Boolean]
      #   true if valid, otherwise false.
      #
      def call(target)
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      # Determines if this validator should be run against the
      # target by evaluating the :if and :unless clauses
      # optionally passed while specifying any validator.
      #
      # @param [Object] target
      #   The resource that we check against.
      #
      # @return [Boolean]
      #   true if should be run, otherwise false.
      #
      # @api private
      def execute?(target)
        if unless_clause = self.unless_clause
          !evaluate_conditional_clause(target, unless_clause)
        elsif if_clause = self.if_clause
          evaluate_conditional_clause(target, if_clause)
        else
          true
        end
      end

      # @api private
      def evaluate_conditional_clause(target, clause)
        if clause.kind_of?(Symbol)
          target.__send__(clause)
        elsif clause.respond_to?(:call)
          clause.call(target)
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
          @options[:allow_nil] ||
            (@options[:allow_blank] && !@options.has_key?(:allow_nil))
        elsif DataMapper::Ext.blank?(value)
          @options[:allow_blank]
        end
      end

      # Returns true if validators are equal
      #
      # Note that this intentionally do
      # validate options equality
      #
      # even though it is hard to imagine a situation
      # when multiple validations will be used
      # on the same field with the same conditions
      # but different options,
      # it happens to be the case every once in a while
      # with inferred validations for strings/text and
      # explicitly given validations with different option
      # (usually as Range vs. max limit for inferred validation)
      #
      # TODO: replace this custom equivalency implementation with Equalizer
      # 
      # @api public
      def ==(other)
        self.class == other.class &&
        self.attribute_name == other.attribute_name &&
        self.if_clause == other.if_clause &&
        self.unless_clause == other.unless_clause &&
        self.options == other.options
      end

      def inspect
        out = "#<#{self.class.name} @attribute_name=#{attribute_name.inspect} "
        out << "@if_clause=#{if_clause.inspect} "         if if_clause
        out << "@unless_clause=#{unless_clause.inspect} " if unless_clause
        out << "@options=#{options.inspect}>"
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
