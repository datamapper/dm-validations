require 'spec_helper'

describe 'DataMapper::Validations::Fixtures::LlamaSpaceship' do
  before :all do
    DataMapper::Validations::Fixtures::LlamaSpaceship.auto_migrate!
  end

  it "validates even non dirty attributes" do
    spaceship = DataMapper::Validations::Fixtures::LlamaSpaceship.create(:type => "custom", :color => "pink")
    spaceship.type = "standard"
    spaceship.should_not be_valid
  end
end
