# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'

module DataMapper
  module Validations
    module Validators
      class Absence < Validator

        def call(target)
          value = target.validation_property_value(attribute_name)
          return true if DataMapper::Ext.blank?(value)

          error_message = self.custom_message ||
            ValidationErrors.default_error_message(:absent, attribute_name)
          add_error(target, error_message, attribute_name)
          false
        end

      end # class Absence

      # Validates that the specified attribute is "blank" via the
      # attribute's #blank? method.
      #
      # @note
      #   dm-core's support lib adds the #blank? method to many classes,
      # @see lib/dm-core/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :unwanted_attribute, String
      #     property :another_unwanted, String
      #     property :yet_again, String
      #
      #     validates_absence_of :unwanted_attribute
      #     validates_absence_of :another_unwanted, :yet_again
      #
      #     # a call to #validate will return false unless
      #     # all three attributes are blank
      #   end
      #
      def validates_absence_of(*attributes)
        validators.add(Validators::Absence, *attributes)
      end

    end # module Validators
  end # module Validations
end # module DataMapper
