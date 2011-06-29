require 'dm-core'

require 'data_mapper/validations/support/ordered_hash'
require 'data_mapper/validations/support/object'

require 'data_mapper/validations/validation_errors'
require 'data_mapper/validations/contextual_validators'
require 'data_mapper/validations/auto_validate'
require 'data_mapper/validations/context'
require 'data_mapper/validations/validators'

module DataMapper
  module Validations

    class ValidationError < StandardError; end

    class InvalidContextError < StandardError; end

  end
end
