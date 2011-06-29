module DataMapper
  module Validations

    AutoValidations = Inferred

    # TODO: this Exception class is not reference with dm-validations
    #   is there *any* reason not to remove it?
    class ValidationError < StandardError; end

    module Validators
      extend Deprecate

      deprecate :validates_is_accepted,   :validates_acceptance_of
      deprecate :validates_is_confirmed,  :validates_confirmation_of
      deprecate :validates_length,        :validates_length_of
      deprecate :validates_is_number,     :validates_numericality_of
      deprecate :validates_is_primitive,  :validates_primitive_type_of
      deprecate :validates_is_unique,     :validates_uniqueness_of
      deprecate :validates_absent,        :validates_absence_of
      deprecate :validates_format,        :validates_format_of

    end
  end

  Validate = Validations

end
