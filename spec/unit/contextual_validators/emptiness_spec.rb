# -*- coding: utf-8 -*-
require 'spec_helper'
require 'unit/contextual_validators/spec_helper'

describe 'DataMapper::Validations::ContextualValidators' do
  before :all do
    @validators = DataMapper::Validations::ContextualValidators.new
  end

  describe "initially" do
    it "is empty" do
      @validators.should be_empty
    end
  end


  describe "after first reference to context" do
    before :all do
      @validators.context(:create)
    end

    it "initializes list of validators for referred context" do
      @validators.context(:create).should be_empty
    end
  end


  describe "after a context being added" do
    before :all do
      @validators.context(:default) << DataMapper::Validations::PresenceValidator.new(:toc, :when => [:publishing])
    end

    it "is no longer empty" do
      @validators.should_not be_empty
    end
  end


  describe "when cleared" do
    before :all do
      @validators.context(:default) << DataMapper::Validations::PresenceValidator.new(:toc, :when => [:publishing])
      @validators.should_not be_empty
      @validators.clear!
    end

    it "becomes empty again" do
      @validators.should be_empty
    end
  end
end
