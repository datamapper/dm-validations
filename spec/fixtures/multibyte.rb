# coding: utf-8

module DataMapper
  module Validation
    module Fixtures
      class Multibyte
        include DataMapper::Resource

        property :id,   Serial
        property :name, String

        validates_length_of :name, :is => 20
      end
    end
  end
end
