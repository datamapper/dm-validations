require 'spec_helper'

describe 'DataMapper::Validations::Fixtures::Product' do
  before :all do
    DataMapper::Validations::Fixtures::ProductCompany.auto_migrate!
    DataMapper::Validations::Fixtures::Product.auto_migrate!

    @parent = DataMapper::Validations::Fixtures::ProductCompany.create(:title => "Apple", :flagship_product => "Macintosh")
    @parent.should be_valid

    @model  = DataMapper::Validations::Fixtures::Product.new(:name => "MacBook Pro", :company => @parent)
    @model.should be_valid
  end

  describe "without company" do
    before :all do
      @model.company = nil
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:company).should == [ 'Company must not be blank' ]
    end
  end
end

describe 'DataMapper::Validations::Fixtures::ProductCompany' do
  before :all do
    @model = DataMapper::Validations::Fixtures::ProductCompany.new(:title => "Apple", :flagship_product => "Macintosh")
  end

  describe 'with invalid products' do
    before :all do
      @model.products = [DataMapper::Validations::Fixtures::Product.new]
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:products).should == [ 'Products must be valid' ]
    end
  end

  describe 'with invalid profile' do
    before :all do
      @model.profile = DataMapper::Validations::Fixtures::Profile.new
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:profile).should == [ 'Profile must be valid' ]
    end
  end

  describe 'with invalid yet_another_profile' do
    before :all do
      @model.yet_another_profile = DataMapper::Validations::Fixtures::Profile.new
    end

    it_should_behave_like "valid model"
  end
end
