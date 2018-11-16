puts "Import apartment data? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  puts "Importing apartments\n"
  
  Neighborhood.all.each do |neighborhood|
    puts "\nSeeding #{neighborhood.name}\n"
    attempts = 0
    until neighborhood.apartments.count == 10 || attempts == 15
      incident = neighborhood.incidents.where("incidents.incident_address is not null").sample
      address = incident.incident_address
      zip = incident.zip
      api = ZillowApi::ListingClient.new
      response_hash = api.get_listings(address, zip)
      if response_hash["searchresults"]["message"]["code"] == "0"
        listing = response_hash["searchresults"]["response"]["results"]["result"]
        if listing.class == Array
          listing.each do |list|
            apartment = Apartment.find_by(zillow_id: list["zpid"])
            if !apartment
              Apartment.create_apartment(list, neighborhood.name)
            end
            attempts += 1
          end
        else
          apartment = Apartment.find_by(zillow_id: listing["zpid"])
          if !apartment
            Apartment.create_apartment(listing, neighborhood.name)
          end
          attempts += 1
        end
      end
      print "\rAttempt # #{attempts}..."
    end
  end

  puts "Apartments imported!"
end