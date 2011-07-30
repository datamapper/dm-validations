require 'spec_helper'

describe 'DataMapper::Validations::WithinValidator' do
  it 'should allow Sets to be passed to the :set option' do
    types = Set.new(%w(home mobile business))

    @model = Class.new do
      include DataMapper::Resource

      def self.name
        'WithinValidatorClass'
      end

      property :id,   DataMapper::Property::Serial
      property :name, String, :auto_validation => false
    end.new

    validator = DataMapper::Validations::WithinValidator.new(:name, :set => types)
    validator.call(@model)

    @model.errors.should_not be_empty
  end
end
