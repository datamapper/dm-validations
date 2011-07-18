module DataMapper
  module Validation
    module Fixtures

      class SmsMessage
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,   Serial
        property :body, Text, :length => (1..500)
      end

    end
  end
end
