require 'spec_helper'
require 'integration/required_field_validator/spec_helper'

describe 'required_field_validator/association_spec' do

  before :all do

    class ::Artist

      include DataMapper::Resource

      property :id,   Serial
      property :name, String,  :auto_validation => false

      has n, :albums

      validates_presence_of :name

    end

    class ::Album

      include DataMapper::Resource

      property :id,        Serial
      property :name,      String,  :auto_validation => false
      property :artist_id, Integer, :index => :artist

      belongs_to :artist

      validates_presence_of :name, :artist

    end

    DataMapper.finalize

    if DataMapper.respond_to?(:auto_migrate!)
      DataMapper.auto_migrate!
    end
  end


  describe 'Album' do

    before do
      @artist = Artist.create(:name => "Oceanlab")
      @album  = @artist.albums.new(:name => "Sirens of the sea")
    end

    describe 'with a missing artist' do
      before do
        @album.artist = nil
      end

      it 'is not valid' do
        @album.should_not be_valid
      end

      it 'has a meaninful error messages on association key property' do
        @album.valid?
        @album.errors.on(:artist).should == [ 'Artist must not be blank' ]
      end
    end

    describe 'with specified artist and name' do
      it 'is valid' do
        @album.should be_valid
      end
    end
  end

end
