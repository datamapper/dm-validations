module DataMapper
  module Validations
    module ModelExtensions

      # @api public
      def create(attributes = {}, *args)
        resource = new(attributes)
        resource.save(*args)
        resource
      end

    end # module ModelExtensions
  end # module Validations

  Model.append_extensions Validations::ModelExtensions

end # module DataMapper
