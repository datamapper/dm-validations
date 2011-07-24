require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'uniqueness' do
  describe 'single attribute' do
    before :all do
      class UniqueEventsSingle
        include DataMapper::Resource

        # storage_names[:default] = 'unique_events_single'

        property :id,         Integer, :key => true
        property :start_year, Integer, :unique => true
      end
      UniqueEventsSingle.auto_migrate!

      @existing = UniqueEventsSingle.create(:id => 1, :start_year => 2008)
      @new = UniqueEventsSingle.new(:id => 2, :start_year => 2008)
    end

    it 'validates' do
      @new.should_not be_valid
    end
  end

  describe 'multiple attributes' do
    before :all do
      class UniqueEventsMultiple
        include DataMapper::Resource

        # storage_names[:default] = 'unique_events_multiple'

        property :id, Integer, :key => true
        property :start_year, Integer, :unique => :years
        property :stop_year,  Integer, :unique => :years
      end
      UniqueEventsMultiple.auto_migrate!

      @new = UniqueEventsMultiple.new(:id => 1, :start_year => 2008, :stop_year => 2009)
    end

    it 'validates uniquness' do
      lambda {
        @new.should_not be_valid
      }.should raise_error(ArgumentError)
    end
  end
end
