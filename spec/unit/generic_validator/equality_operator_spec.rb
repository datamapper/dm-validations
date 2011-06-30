require 'spec_helper'

describe 'DataMapper::Validations::GenericValidator' do
  describe "when types and fields are equal" do
    it "returns true" do
      DataMapper::Validations::Validators::Presence.new(:name).
        should == DataMapper::Validations::Validators::Presence.new(:name)
    end
  end


  describe "when types differ" do
    it "returns false" do
      DataMapper::Validations::Validators::Presence.new(:name).
        should_not == DataMapper::Validations::Validators::Uniqueness.new(:name)
    end
  end


  describe "when property names differ" do
    it "returns false" do
      DataMapper::Validations::Validators::Presence.new(:first_name).
        should_not == DataMapper::Validations::Validators::Presence.new(:last_name)
    end
  end
end
