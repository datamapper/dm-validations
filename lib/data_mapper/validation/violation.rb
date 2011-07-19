require 'forwardable'
require 'data_mapper/validation/message_transformer'

module DataMapper
  module Validation

    class Violation

      def self.default_transformer
        @default_transformer ||= MessageTransformer::Default.new
      end

      def self.default_transformer=(transformer)
        @default_transformer = transformer
      end

      attr_reader :resource
      attr_reader :custom_message
      attr_reader :rule
      attr_reader :attribute_name

      # Configure a Violation instance
      # 
      # @param [DataMapper::Resource, Object] resource
      #   the validated object; either a DataMapper::Resource,
      #   or a plain old Ruby Object
      # @param [String, #call, Hash] message
      #   an optional custom message for this Violation
      # @param [Rule] rule
      #   the Rule whose violation triggered the creation of the receiver
      # @param [Symbol] attribute_name
      #   the name of the attribute whose validation rule was violated
      #   or nil, if a Rule was provided.
      # 
      def initialize(resource, message = nil, rule = nil, attribute_name = nil)
        unless message || rule
          raise ArgumentError, "expected +message+ or +rule+"
        end

        @resource       = resource
        @rule           = rule
        @attribute_name = attribute_name
        @custom_message = evaluate_message(message)
      end

      # @api public
      def message(transformer = Undefined)
        return @custom_message if @custom_message

        transformer = Undefined == transformer ? self.transformer : transformer

        transformer.transform(self)
      end

      # @api public
      alias_method :to_s, :message

      # @api public
      def attribute_name
        if @attribute_name
          @attribute_name
        elsif rule
          rule.attribute_name
        end
      end

      # @api public
      def violation_type
        rule ? rule.violation_type(resource) : nil
      end

      # @api public
      def violation_data
        rule ? rule.violation_data(resource) : nil
      end

      def transformer
        if resource.respond_to?(:model) && transformer = resource.model.validators.transformer
          transformer
        else
          Violation.default_transformer
        end
      end

      def evaluate_message(message)
        if message.respond_to?(:call)
          if resource.respond_to?(:model) && resource.model.respond_to?(:properties)
            property = resource.model.properties[attribute_name]
            message.call(resource, property)
          else
            message.call(resource)
          end
        else
          message
        end
      end

      # In general we want Equalizer-type equality/equivalence,
      # but this allows direct equivalency test against Strings, which is handy
      def ==(other)
        if other.respond_to?(:to_str)
          self.to_s == other.to_str
        else
          super
        end
      end

      module Equalization
        extend Equalizer

        EQUALIZE_ON = [:resource, :rule, :custom_message, :attribute_name]

        equalize *EQUALIZE_ON

        # TODO: could this definition of #inspect be moved into Equalizer itself?
        #   It would provide a reasonable default implementation of #inspect
        #   It would eliminate the need for an EQUALIZE_ON constant (and the splat)
        def inspect
          out = "#<#{self.class.name}"
          self.class::Equalization::EQUALIZE_ON.each do |ivar_name|
            out << " @#{ivar_name}=#{__send__(ivar_name).inspect}"
          end
          out << ">"
        end
      end
      include Equalization

    end # class Violation

  end # module Validation
end # module DataMapper
