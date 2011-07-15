module DataMapper
  module Validations

    # TODO: this Exception class is not referenced within dm-validations
    #   any reason not to remove it?
    class ValidationError < StandardError; end

    class ContextualRuleSets
      extend Deprecate

      deprecate :execute, :validate
      deprecate :clear!,  :clear
    end

    class Rule
      extend Deprecate

      # TODO: remove :field_name alias
      deprecate :field_name, :attribute_name
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

  end # module Validations

  Validate = Validations

end # module DataMapper
