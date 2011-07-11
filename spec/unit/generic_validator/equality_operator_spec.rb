require 'spec_helper'

describe 'DataMapper::Validations::GenericValidator' do
  describe "when types and fields are equal" do
    it "returns true" do
      DataMapper::Validations::Validator::Presence.new(:name).
        should == DataMapper::Validations::Validator::Presence.new(:name)
    end
  end


  describe "when types differ" do
    it "returns false" do
      DataMapper::Validations::Validator::Presence.new(:name).
        should_not == DataMapper::Validations::Validator::Uniqueness.new(:name)
    end
  end


  describe "when property names differ" do
    it "returns false" do
      DataMapper::Validations::Validator::Presence.new(:first_name).
        should_not == DataMapper::Validations::Validator::Presence.new(:last_name)
    end
  end
end
