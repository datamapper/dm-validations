# -*- coding: utf-8 -*-
require 'spec_helper'
require 'unit/contextual_validators/spec_helper'

describe 'DataMapper::Validations::ContextualRuleSet' do
  before :all do
    @validators = DataMapper::Validations::ContextualRuleSet.new
  end

  describe "#execute(name, target)" do
    before do
      @validator_one = DataMapper::Validations::Rule::Presence.new(:name)
      @validator_two = DataMapper::Validations::Rule::Within.new(:operating_system, :set => ["Mac OS X", "Linux", "FreeBSD", "Solaris"])

      @validators.context(:default) << @validator_one << @validator_two
    end


    describe "when target satisfies all validators" do
      before do
        @target = DataMapper::Validations::Fixtures::PieceOfSoftware.new(:name => 'gcc', :operating_system => "Mac OS X")
        @validator_one.call(@target).should be(true)
        @validator_two.call(@target).should be(true)

        @result = @validators.execute(:default, @target)
      end

      it "returns true" do
        @result.should be(true)
      end
    end


    describe "when target does not satisfy all validators" do
      before do
        @target = DataMapper::Validations::Fixtures::PieceOfSoftware.new(:name => 'Skitch', :operating_system => "Haiku")
        @validator_one.call(@target).should be(true)
        @validator_two.call(@target).should be(false)

        @result = @validators.execute(:default, @target)
      end

      it "returns false" do
        @result.should be(false)
      end
    end
  end
end
