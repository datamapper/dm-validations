module DataMapper
  module Validation
    module ModelExtensions

      # @api public
      def create(attributes = {}, *args)
        resource = new(attributes)
        resource.save(*args)
        resource
      end

    end # module ModelExtensions
  end # module Validation

  Model.append_extensions Validation::ModelExtensions

end # module DataMapper
