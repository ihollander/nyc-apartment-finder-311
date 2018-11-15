class Apartment < ApplicationRecord
    belongs_to :neighborhood
    has_many :user_apartments, dependent: :destroy
    has_many :users, through: :user_apartments

    def self.find_or_create_from_api(neighborhood_name)
      hash = self.find_listings_in_neighborhood(neighborhood_name)
      listings = hash["searchresults"]["response"]["results"]["result"]
      @neighborhood = Neighborhood.find_by(name: neighborhood_name)
      listings.each do |listing|
        apartment = Apartment.find_by(zillow_id: listing["zpid"])
        if !apartment
          create_apartment(listing)
        end
      end
    end

    def self.find_listings_in_neighborhood(name)
      @client_communicator = ZillowApi::ListingClient.new
      @array_of_zips = Incident.get_zips_from_neighborhoods(name)
      @array_of_zips.each do |zip|
        @listings = @client_communicator.get_listings(name, zip)
      end
      @listings
    end

    def add_image_and_description
      @second_communicator = ZillowApi::ListingClient.new
      hash = @second_communicator.get_listing_details(self.zillow_id)
      if pulic_data?(hash) && hash["updatedPropertyDetails"]["response"]["images"]
        if hash["updatedPropertyDetails"]["response"]["images"]
          # self.images = hash["updatedPropertyDetails"]["response"]["images"]["image"]["url"]
          if hash["updatedPropertyDetails"]["response"]["images"]["image"]["url"].class == Array
            hash["updatedPropertyDetails"]["response"]["images"]["image"]["url"].each do |url|
              if test_image_size(url)
                self.images << url
              end
            end
          end
          self.description = hash["updatedPropertyDetails"]["response"]["homeDescription"]
        end
      end
    end

    def pulic_data?(hash)
      if hash["updatedPropertyDetails"]["message"]["code"] != "0"
        false
      else
        true
      end
    end

    def self.create_apartment(listing)
      listings_hash = {
        street: listing["address"]["street"],
        zipcode: listing["address"]["zipcode"],
        city: listing["address"]["city"],
        state: listing["address"]["state"],
        latitude: listing["address"]["latitude"],
        longitude: listing["address"]["longitude"],
        url: listing["links"]["homedetails"],
        value: listing["zestimate"]["amount"],
        price_change: listing["zestimate"]["oneWeekChange"]["deprecated"],
        zillow_id: listing["zpid"],
        sqft: listing["finishedSqFt"],
        bedrooms: listing["bedrooms"],
        bathrooms: listing["bathrooms"],
        year_built: listing["yearBuilt"],
        neighborhood_id: @neighborhood.id
      }
      apartment = Apartment.new(listings_hash)
      apartment.add_image_and_description
      if apartment.images.count != 0
        apartment.save
      end
    end

    def parse_value(value)
      "$#{value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    end

    def test_image_size(url)
      answer = true
      if (FastImage.size(url)[1] * 1.332) >= FastImage.size(url)[0]
        answer = false
      end
      answer
    end

    def pluralize_bedroom(item)
      string = "Bedroom"
      if item != 1
        string = "Bedrooms"
      end
      string
    end

    def pluralize_bathroom(item)
      string = "Bathroom"
      if item != 1
        "Bathrooms"
      end
      string
    end

    def value?(value)
      !!value
    end

    def next
      self.class.where("id > ?", id).first
    end
  
    def previous
      self.class.where("id < ?", id).last
    end

  end # end of apartment class


    # def validation_logic(code, message)
    #   response_status = false
    #   if code == "508" || code == "507"
    #     "Error: no exact match found for input address"
    #   elsif code == "508" || code == "507"
    #     "Failed to resolve city/state (or zip code). message: #{message}"
    #   elsif code == "3" || code == "4" || code == "505"
    #     "The Zillow API is currently unavailable"
    #   elsif code == "1"
    #     "Service error: #{message}"
    #   elseif code == "2"
    #     "Invalid Zillow API key"
    #   elsif code == "0"
    #     "Request successfully processed"
    #     response_status = true
    #   end
    # end
