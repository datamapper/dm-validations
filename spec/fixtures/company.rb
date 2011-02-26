# -*- coding: utf-8 -*-

module DataMapper
  module Validations
    module Fixtures
      class Company
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial
        property :title,    String
        property :type,     Discriminator


        #
        # Validations
        #

        validates_presence_of :title, :message => "Company name is a required field"

      end

      class ServiceCompany < Company

        #
        # Properties
        #

        without_auto_validations do
          property :area_of_expertise, String, :length => (1..60)
        end

        #
        # Validations
        #

        validates_presence_of :area_of_expertise
      end

      class ProductCompany < Company

        #
        # Properties
        #

        without_auto_validations do
          property :flagship_product, String, :length => (1..60)
        end

        #
        # Validations
        #

        validates_presence_of :title, :message => "Product company must have a name"
        validates_presence_of :flagship_product

        has n, :products, :child_key => [:company_id]
        has 1, :profile
        has 0..1, :alternate_profile, :model => "Profile"

        without_auto_validations do
          has 0..1, :yet_another_profile, :model => "Profile"
        end
      end

      class Profile
        include DataMapper::Resource

        property :id, Serial
        belongs_to :product_company
        property :description, Text, :required => true
      end

      class Product
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,   Serial
        property :name, String, :required => true

        #
        # Associations
        #

        belongs_to :company, :model => DataMapper::Validations::Fixtures::ProductCompany

        #
        # Validations
        #

        validates_presence_of :company
      end
    end
  end
end
