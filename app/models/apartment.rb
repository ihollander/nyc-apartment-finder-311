class Apartment < ApplicationRecord
    belongs_to :neighborhood
    has_many :user_apartments, dependent: :destroy
    has_many :users, through: :user_apartments

    def self.seed
      Neighborhood.all.each do |neighborhood|
        seed_logic(neighborhood)
      end
      puts "completed seed"
      # test
    end

    def self.seed_logic(neighborhood)
      @neighborhood = Neighborhood.find_by(name: neighborhood.name)
      if Apartment.find_by(neighborhood_id: neighborhood.id) == nil
        puts "seeding #{neighborhood.name}"
        apartment = Apartment.find_or_create_from_api(neighborhood.name)

        if apartment == nil
          x = 0
          second_logic(neighborhood, x)
          byebug
        end
      else
        puts "already have apartments for #{neighborhood.name}"
      end
    end

    def self.second_logic(neighborhood, x)
      # if Apartment.find_by(neighborhood_id: neighborhood.id) == nil
      if x < 9
        @client_communicator = ZillowApi::ListingClient.new
        address = neighborhood.find_street
        @listings = @client_communicator.get_listings(address[0], address[1])
        byebug
        new_listings = third_logic(@listings, neighborhood, x)
        create_round_two(new_listings)
      end
    end

    def self.third_logic(listings, neighborhood, x)
      if listings["searchresults"]["message"]["code"] == "508"
        x += 1
        second_logic(neighborhood, x)
      else
        listings
      end
    end

    def self.create_round_two(listings)
      if listings["searchresults"]["message"]["code"] != "508" && listings["searchresults"]["message"]["code"] != "7"
        listings = listings["searchresults"]["response"]["results"]["result"]
        if listings.class == Array
          listings.each do |listing|
            apartment = Apartment.find_by(zillow_id: listing["zpid"])
            if !apartment
              create_apartment(listing)
            end
          end
        else
          apartment = Apartment.find_by(zillow_id: listings["zpid"])
          if !apartment
            create_apartment(listings)
          end
        end
      end
    end

    # def test
    #   Neighborhood.all.each do |neighborhood|
    #     if neighborhood.appartments.count < 10
    #       puts "re-seeding #{neighborhood}"
    #       Apartment.find_or_create_from_api(neighborhood)
    #     end
    #   end
    # end

    def self.find_or_create_from_api(neighborhood_name)
      hash = self.find_listings_in_neighborhood(neighborhood_name)
      listings = hash["searchresults"]["response"]["results"]["result"]
      listings.each do |listing|
        apartment = Apartment.find_by(zillow_id: listing["zpid"])
        if !apartment
          create_apartment(listing, neighborhood_name)
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
      else
        self.images << "https://www.gumtree.com/static/1/resources/assets/rwd/images/orphans/a37b37d99e7cef805f354d47.noimage_thumbnail.png"
      end
    end

    def pulic_data?(hash)
      if hash["updatedPropertyDetails"]["message"]["code"] != "0"
        false
      else
        true
      end
    end

    def self.create_apartment(listing, neighborhood_name)
      @neighborhood = Neighborhood.find_by(name: neighborhood_name)
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
