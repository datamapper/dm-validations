module DataMapper
  # for options_with_message
  # TODO: rename :auto_validation => :infer_validation
  Property.accept_options :auto_validation, :validates, :set, :format, :message, :messages

  module Validation
    module Inferred

      # @api private
      def property(*)
        property = super

        if property.options.fetch(:auto_validation, true) && !disabled_auto_validations?
          rule_definitions = Validation::Inferred.rules_for_property(property)
          rule_definitions.each do |rule_class, attribute_name, options|
            validation_rules.add(rule_class, [attribute_name], options)
          end
        end

        # FIXME: explicit return needed for YARD to parse this properly
        return property
      end

      # attr_accessor :infer_validations

      # TODO: replace the @disabled_auto_validations reader methods with
      #   a positive statement instead of negative (instead of skip/disable, etc)
      #   eg., @infer_validations, #infer_validations?
      #
      # Checks whether auto validations are currently
      # disabled (see +disable_auto_validations+ method
      # that takes a block)
      #
      # @return [TrueClass, FalseClass]
      #   true if auto validation is currently disabled
      #
      # @api public
      # def infer_validations?
      #   defined?(@infer_validations) ? @infer_validations : true
      # end

      # TODO: why are there 3 entry points to this ivar?
      # #disable_auto_validations, #disabled_auto_validations?, #auto_validations_disabled?
      attr_reader :disable_auto_validations

      # Checks whether auto validations are currently
      # disabled (see +disable_auto_validations+ method
      # that takes a block)
      #
      # @return [TrueClass, FalseClass]
      #   true if auto validation is currently disabled
      #
      # @api semipublic
      def disabled_auto_validations?
        @disable_auto_validations || false
      end

      # TODO: deprecate all but one of these 3 variants
      alias_method :auto_validations_disabled?, :disabled_auto_validations?

      # Disable generation of validations for the duration of the given block
      #
      # @api public
      def without_auto_validations
        previous, @disable_auto_validations = @disable_auto_validations, true
        yield
      ensure
        @disable_auto_validations = previous
        self
      end

      # Infer validations for a given property. This will only occur
      # if the option :auto_validation is either true or left undefined.
      #
      #   Triggers that generate validator creation
      #
      #   :required => true
      #       Setting the option :required to true causes a Rule::Presence
      #       to be created for the property
      #
      #   :length => 20
      #       Setting the option :length causes a Rule::Length to be created
      #       for the property.
      #       If the value is a Integer the Rule will have :maximum => value.
      #       If the value is a Range the Rule will have :within => value.
      #
      #   :format => :predefined / lambda / Proc
      #       Setting the :format option causes a Rule::Format to be created
      #       for the property
      #
      #   :set => ["foo", "bar", "baz"]
      #       Setting the :set option causes a Rule::Within to be created
      #       for the property
      #
      #   Integer type
      #       Using a Integer type causes a Rule::Numericalness to be created
      #       for the property.  The Rule's :integer_only option is set to true
      #
      #   BigDecimal or Float type
      #       Using a Integer type causes a Rule::Numericalness to be created
      #       for the property.  The Rule's :integer_only option will be set
      #       to false, and precision/scale will be set to match the Property
      #
      #
      #   Messages
      #
      #   :messages => {..}
      #       Setting :messages hash replaces standard error messages
      #       with custom ones. For instance:
      #       :messages => {:presence => "Field is required",
      #                     :format => "Field has invalid format"}
      #       Hash keys are: :presence, :format, :length, :is_unique,
      #                      :is_number, :is_primitive
      #
      #   :message => "Some message"
      #       It is just shortcut if only one validation option is set
      #
      # @api private
      def self.rules_for_property(property)
        rule_definitions = []

        # all inferred rules should not be skipped when the value is nil
        #   (aside from Rule::Presence/Rule::Absence)
        opts = { :allow_nil => true }

        if property.options.key?(:validates)
          opts[:context] = property.options[:validates]
        end

        rule_definitions << infer_presence(  property, opts.dup)
        rule_definitions << infer_length(    property, opts.dup)
        rule_definitions << infer_format(    property, opts.dup)
        rule_definitions << infer_uniqueness(property, opts.dup)
        rule_definitions << infer_within(    property, opts.dup)
        rule_definitions << infer_type(      property, opts.dup)

        rule_definitions.compact
      end

    private

      # @api private
      def self.infer_presence(property, options)
        return if property.allow_blank? || property.serial?

        validation_options = options_with_message(options, property, :presence)

        [Rule::Presence, property.name, validation_options]
      end

      # @api private
      def self.infer_length(property, options)
        # TODO: return unless property.primitive <= String (?)
        return unless (property.kind_of?(Property::String) ||
                       property.kind_of?(Property::Text))
        length = property.options.fetch(:length, Property::String.length)


        if length.is_a?(Range)
          if length.last == Infinity
            raise ArgumentError, "Infinity is not a valid upper bound for a length range"
          end
          options[:within]  = length
        else
          options[:maximum] = length
        end

        validation_options = options_with_message(options, property, :length)

        [Rule::Length, property.name, validation_options]
      end

      # @api private
      def self.infer_format(property, options)
        return unless property.options.key?(:format)

        options[:with] = property.options[:format]

        validation_options = options_with_message(options, property, :format)

        [Rule::Format, property.name, validation_options]
      end

      # @api private
      def self.infer_uniqueness(property, options)
        return unless property.options.key?(:unique)

        case value = property.options[:unique]
          when Array, Symbol
            # TODO: fix this to behave like :unique_index
            options[:scope] = Array(value)

            validation_options = options_with_message(options, property, :is_unique)
            [Rule::Uniqueness, property.name, validation_options]
          when TrueClass
            validation_options = options_with_message(options, property, :is_unique)
            [Rule::Uniqueness, property.name, validation_options]
        end
      end

      # @api private
      def self.infer_within(property, options)
        return unless property.options.key?(:set)

        options[:set] = property.options[:set]

        validation_options = options_with_message(options, property, :within)
        [Rule::Within, property.name, validation_options]
      end

      # @api private
      def self.infer_type(property, options)
        return if property.respond_to?(:custom?) && property.custom?

        if property.kind_of?(Property::Numeric)
          options[:gte] = property.min if property.min
          options[:lte] = property.max if property.max
        end

        if Integer == property.load_as
          options[:integer_only] = true

          validation_options = options_with_message(options, property, :is_number)
          [Rule::Numericalness, property.name, validation_options]
        elsif (BigDecimal == property.load_as ||
               Float == property.load_as)
          options[:precision] = property.precision
          options[:scale]     = property.scale

          validation_options = options_with_message(options, property, :is_number)
          [Rule::Numericalness, property.name, validation_options]
        else
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          validation_options = options_with_message(options, property, :is_primitive)
          [Rule::PrimitiveType, property.name, validation_options]
        end
      end

      # TODO: eliminate this;
      #   mutating one arg based on a non-obvious interaction of the other two...
      #   well, it makes my skin crawl.
      #
      # @api private
      def self.options_with_message(base_options, property, validator_name)
        options = base_options.clone
        opts    = property.options

        if opts.key?(:messages)
          options[:message] = opts[:messages][validator_name]
        elsif opts.key?(:message)
          options[:message] = opts[:message]
        end

        options
      end

    end # module Inferred
  end # module Validation

  Model.append_extensions Validation::Inferred

end # module DataMapper
