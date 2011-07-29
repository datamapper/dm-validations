require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'uniqueness' do
  describe 'single column' do
    before :all do
      @klass = Class.new do
        include DataMapper::Resource

        def self.name
          'UniqueEventsSingle'
        end

        property :id,         Integer, :key => true
        property :start_year, Integer, :unique => true
      end
      @klass.auto_migrate!

      @existing = @klass.create(:id => 1, :start_year => 2008)
      @new = @klass.new(:id => 2, :start_year => 2008)
    end

    it 'validates' do
      @new.should_not be_valid
    end
  end

  describe 'multiple columns' do
    before :all do
      @klass = Class.new do
        include DataMapper::Resource

        def self.name
          'UniqueEventsMultiple'
        end

        property :id, Integer, :key => true
        property :start_year, Integer, :unique => :years
        property :stop_year,  Integer, :unique => :years
      end
      @klass.auto_migrate!

      @new = @klass.new(:id => 1, :start_year => 2008, :stop_year => 2009)
    end

    it 'validates uniquness' do
      lambda {
        @new.should_not be_valid
      }.should raise_error(ArgumentError)
    end
  end
end
