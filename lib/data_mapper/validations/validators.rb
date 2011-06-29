# -*- encoding: utf-8 -*-

module DataMapper
  module Validations
    module Validators
      extend Deprecate
    end # module Validators
  end # module Validations

  Model.append_extensions Validations::Validators

end # module DataMapper

require 'data_mapper/validations/validators/abstract'

require 'data_mapper/validations/validators/absence'
require 'data_mapper/validations/validators/acceptance'
require 'data_mapper/validations/validators/block'
require 'data_mapper/validations/validators/confirmation'
require 'data_mapper/validations/validators/format'
require 'data_mapper/validations/validators/length'
require 'data_mapper/validations/validators/method'
require 'data_mapper/validations/validators/numericality'
require 'data_mapper/validations/validators/presence'
require 'data_mapper/validations/validators/primitive_type'
require 'data_mapper/validations/validators/uniqueness'
require 'data_mapper/validations/validators/within'
