
require 'data_mapper/validation/support/ordered_hash'
require 'data_mapper/validation/violation'

module DataMapper
  module Validation

    class ViolationSet

      include Enumerable

      # @api private
      attr_reader :resource

      # @api private
      attr_reader :errors
      # TODO: why was this private?
      private :errors

      # TODO: replace OrderedHash with OrderedSet and remove vendor'd OrderedHash
      def initialize(resource)
        @resource = resource
        @errors   = OrderedHash.new { |h,k| h[k] = [] }
      end

      # Clear existing validation errors.
      # 
      # @api public
      def clear
        errors.clear
      end

      # Add a validation error. Use the attribute_name :general if the errors
      # does not apply to a specific field of the Resource.
      #
      # @param [Symbol, Violation] attribute_name_or_violation
      #   The name of the field that caused the error, or
      #   the Violation which describes the validation error
      # @param [String, #call, Hash] message
      #   The message to add.
      # 
      # @see Violation#initialize
      # 
      # @api public
      def add(attribute_name_or_violation, message = nil)
        violation = 
          if attribute_name_or_violation.kind_of?(Violation)
            attribute_name_or_violation
          else
            Violation.new(resource, message, nil, attribute_name_or_violation)
          end

        errors[violation.attribute_name] << violation
      end

      # Collect all errors into a single list.
      # 
      # @api public
      def full_messages
        errors.inject([]) do |list, (attribute_name, errors)|
          messages = errors
          messages = errors.full_messages if errors.respond_to?(:full_messages)
          list += messages
        end
      end

      # Return validation errors for a particular attribute_name.
      #
      # @param [Symbol] attribute_name
      #   The name of the field you want an error for.
      #
      # @return [Array(Violation, String), NilClass]
      #   Array of Violations or Strings, if there are errors on +attribute_name+
      #   nil if there are no errors on +attribute_name+
      # 
      # @api public
      # 
      # TODO: use a data structure that ensures uniqueness
      def on(attribute_name)
        attribute_violations = errors[attribute_name]
        attribute_violations.empty? ? nil : attribute_violations.uniq
      end

      # @api public
      def each
        errors.each_value do |v|
          yield(v) unless DataMapper::Ext.blank?(v)
        end
      end

      # @api public
      def empty?
        errors.all? { |attribute_name, errors| errors.empty? }
      end

      # @api public
      # 
      # FIXME: calling #to_sym on uncontrolled input is an
      # invitation for a memory leak
      def [](attribute_name)
        errors[attribute_name.to_sym]
      end

      def method_missing(meth, *args, &block)
        errors.send(meth, *args, &block)
      end

      def respond_to?(method)
        super || errors.respond_to?(method)
      end

    end # class ViolationSet

  end # module Validation
end # module DataMapper
