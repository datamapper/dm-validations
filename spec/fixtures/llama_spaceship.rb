module DataMapper
  module Validations
    module Fixtures
      class LlamaSpaceship
        include DataMapper::Resource

        property :id, Serial
        property :type, String
        property :color, String

        validates_format_of :color, :with => /^red|black$/, :if => Proc.new { |spaceship| spaceship.type == "standard" }
      end
    end
  end
end
