# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'
require 'data_mapper/validations/validators/method'

module DataMapper
  module Validations
    module Validators

      # TODO: re-implement this in a way that doesn't pollute the validated
      # class. It shouldn't be that hard. Maybe start with this?
      # class Block < Method
      #   def initialize(attribute_name, options = {})
      #     
      #   end
      # end


    end # module Validators
  end # module Validations
end # module DataMapper
