module DataMapper
  module Validations
    module Fixtures
      # Mittelschauzer is a type of dog. The More You Know.
      class Mittelschnauzer

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        without_auto_validations do
          property :name,   String, :key => true
          property :height, Float
        end

        attr_accessor :owner

        #
        # Validations
        #

        validates_length_of :name,  :min => 2, :allow_nil => false
        validates_length_of :owner, :min => 2

        validates_numericality_of :height, :lt => 55.2

        def self.valid_instance
          new(:name => "Roudolf Wilde", :height => 50.4, :owner => 'don')
        end
      end # Mittelschnauzer
    end
  end
end
