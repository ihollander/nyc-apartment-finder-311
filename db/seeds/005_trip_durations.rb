puts "Calculate route times for Journeys table? [y/n]"

# need to reseed this because most looks to be seeded with driving info...
# update the seed CLI to select origin borough and destination borough
# figure out a good way to remove bad data
# or add a trip type column and seed for public transit in a separate column
if STDIN.gets.chomp.downcase == "y"
  boroughs = Neighborhood.group(:borough).count
  puts "Enter an origin borough to seed: "
  boroughs.each_with_index do |borough, index|
    puts "#{index+1}. #{borough[0]}"
  end
  input = STDIN.gets.chomp.to_i
  origin = boroughs.keys[input - 1]
  puts "Enter a destination borough to seed: "
  boroughs.each_with_index do |borough, index|
    puts "#{index+1}. #{borough[0]}"
  end
  input = STDIN.gets.chomp.to_i
  destination = boroughs.keys[input - 1]

  if origin && destination
    journeys = Journey.joins(:neighborhood_a).joins(:neighborhood_b).where("neighborhoods.borough = ? and neighborhood_bs_journeys.borough = ? and journeys.transit_trip_duration is null", origin, destination)
    journeys_count = journeys.count
    puts "This will seed data from the Google Maps API for #{journeys_count} routes. Continue? [y/n]\n"
    if STDIN.gets.chomp.downcase == "y"
      counter = 1
      journeys.each do |journey|
        # try public transit
        duration = journey.get_trip_duration("transit")
        # then driving
        if !duration
          duration = journey.get_trip_duration("driving")
        end
        # then by zip...
        if !duration
          duration = journey.get_trip_duration_by_zip("transit")
        end
        
        if duration
          journey.transit_trip_duration = duration
          journey.save
        end
        print "\rSeeded #{counter} of #{journeys_count}"
        counter += 1
      end
      puts "\nDone seeding routes."
    end
  end
end
