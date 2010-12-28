require 'spec_helper'
require 'integration/automatic_validation/spec_helper'


{ :float => Float, :big_decimal => BigDecimal }.each do |column, type|
  describe "#{type} property" do
    before :all do
      SailBoat.auto_migrate!

      @model = SailBoat.new(:id => 1)
    end

    describe "with an integer value" do
      before :all do
        @model.attributes = {column => 1}
      end

      it_should_behave_like "valid model"
    end

    describe "with a float value" do
      before :all do
        @model.attributes = {column => 1.0}
      end

      it_should_behave_like "valid model"
    end

    describe "with a BigDecimal value" do
      before :all do
        @model.attributes = {column => BigDecimal('1')}
      end

      it_should_behave_like "valid model"
    end

    describe "with an uncoercible value" do
      before :all do
        @model.attributes = {column => "foo"}
      end

      it_should_behave_like "invalid model"
    end
  end
end
