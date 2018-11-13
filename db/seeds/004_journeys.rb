puts "Import/overwrite journey data? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  puts "Importing journies between neighborhoods\n"
  Journey.destroy_all
  
  total_neighborhoods = Neighborhood.all.count
  Neighborhood.all.each do |neighborhood_a|
    Neighborhood.all.each do |neighborhood_b|
      if neighborhood_a != neighborhood_b
        route_1 = Journey.find_by(neighborhood_a: neighborhood_a, neighborhood_b: neighborhood_b)
        route_2 = Journey.find_by(neighborhood_a: neighborhood_b, neighborhood_b: neighborhood_a)
        unless route_1 || route_2
          Journey.create(neighborhood_a: neighborhood_a, neighborhood_b: neighborhood_b)
        end
      end
    end
    print "\rNeighborhood #{neighborhood_a.id} of #{total_neighborhoods} imported"
  end
  puts "Journies imported!"
end