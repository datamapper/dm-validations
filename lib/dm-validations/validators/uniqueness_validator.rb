module DataMapper
  module Validations

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class UniquenessValidator < GenericValidator
      include DataMapper::Assertions

      def initialize(field_name, options = {})
        assert_kind_of 'scope', options[:scope], Array, Symbol if options.has_key?(:scope)
        super

        set_optional_by_default
      end

      def call(target)
        return true if valid?(target)

        error_message = @options[:message] || ValidationErrors.default_error_message(:taken, field_name)
        add_error(target, error_message, field_name)

        false
      end

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)

        opts = {
          :fields    => target.model.key(target.repository.name),
          field_name => value,
        }

        Array(@options[:scope]).each {|subject|
          if target.respond_to?(subject)
            opts[subject] = target.__send__(subject)
          else
            raise ArgumentError, "Could not find property to scope by: #{subject}. Note that :unique does not currently support arbitrarily named groups, for that you should use :unique_index with an explicit validates_uniqueness_of."
          end
        }

        resource = DataMapper.repository(target.repository.name) { target.model.first(opts) }

        return true if resource.nil?

        target.saved? && resource.key == target.key
      end
    end # class UniquenessValidator

    module ValidatesUniqueness
      extend Deprecate

      # Validate the uniqueness of a field
      #
      def validates_uniqueness_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validations::UniquenessValidator)
      end

      deprecate :validates_is_unique, :validates_uniqueness_of

    end # module ValidatesIsUnique
  end # module Validations
end # module DataMapper
