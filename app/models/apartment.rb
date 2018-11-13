class Apartment < ApplicationRecord
    belongs_to :neighborhood

    def self.find_listings_in_neighborhood(name)
      @client_communicator = ZillowApi::ListingClient.new
      @array_of_zips = Incident.get_zips_from_neighborhoods(name)
      @array_of_zips.each do |zip|
        @listings = @client_communicator.get_listings(name, zip)
      end
      @listings
    end

    def self.find_or_create_from_api(neighborhood_name)
      hash = self.find_listings_in_neighborhood(neighborhood_name)
      listings = hash["searchresults"]["response"]["results"]["result"]
      @neighborhood = Neighborhood.find_by(name: neighborhood_name)
      listings.each do |listing|
        apartment Apartment.find_by(zillow_id: listing["zpid"])
        unless apartment ### passed into array
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
          neighborhood_id: @neighborhood.id
          }
          apartment = Apartment.create(listings_hash)
        end
        apartment
      end


      # Apartment.find_by(zillow_id: )
      #look through appartments to see if zillow id exists
      #if doesnt exist then persist
    end
    # def array_of_addresses(neighbourhood, array_of_zips)
    #   array = []
    #   array_of_addresses_by_zips = api_hash(neighbourhood, array_of_zips)
    #   array_of_addresses_by_zips.each do |hash|
    #     hash["searchresults"]["response"]["results"]["result"].each do |r|
    #       binding.pry
    #       array << r["address"]
    #     end
    #   end
    #   array
    # end


    # def api_hash(neighbourhood, array_of_zips)
    #   array_of_addresses_by_zips = []
    #   array_of_zips.each do |zip|
    #     hash = api_request(neighbourhood, zip)
    #     if validate_response(hash).class == "String"
    #       puts  "error"
    #     end
    #     array_of_addresses_by_zips << hash
    #   end
    #   array_of_addresses_by_zips
    # end

    # def validate_response(response)
    #   response_code = response["searchresults"]["message"]["code"]
    #   response_message = response["searchresults"]["message"]["text"]
    #   validation_logic(response_code, response_message)
    # end

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



end
