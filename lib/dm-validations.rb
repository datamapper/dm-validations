require 'dm-core'

require 'data_mapper/validation/support/ordered_hash'
require 'data_mapper/validation/support/object'

require 'data_mapper/validation'

require 'data_mapper/validation/exceptions'
require 'data_mapper/validation/context'
require 'data_mapper/validation/violation'
require 'data_mapper/validation/error_set'

require 'data_mapper/validation/rule'
require 'data_mapper/validation/rule_set'
require 'data_mapper/validation/contextual_rule_set'

require 'data_mapper/validation/resource'
require 'data_mapper/validation/model_extensions'
require 'data_mapper/validation/inferred'

# TODO: eventually drop this from here and let it be an opt-in require
require 'data_mapper/validation/backward'
# TODO: consider moving to a version-specific backwards-compatibility file:
# require 'data_mapper/validation/backward/1_1'
