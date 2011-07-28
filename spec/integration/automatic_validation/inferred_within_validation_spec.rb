require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'A model with a :set & :default options on a property' do
  before :all do
    class ::LimitedBoat
      include DataMapper::Resource
      property :id,      DataMapper::Property::Serial
      property :limited, String, :set => %w[ foo bar bang ], :default => 'foo'
    end

    DataMapper.finalize

    if DataMapper.respond_to?(:auto_migrate!)
      DataMapper.auto_migrate!
    end
  end

  describe "without value on that property" do
    before :all do
      @model = LimitedBoat.new
    end

    # default value is respected
    it_should_behave_like "valid model"
  end

  describe "without value on that property that is not in allowed range/set" do
    before :all do
      @model = LimitedBoat.new(:limited => "blah")
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:limited).should == [ 'Limited must be one of foo, bar, bang' ]
    end
  end
end
