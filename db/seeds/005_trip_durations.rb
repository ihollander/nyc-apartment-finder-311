puts "Calculate route times for Journeys table? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  counties = Neighborhood.group(:county).count
  puts "Enter a County to seed: "
  counties.each_with_index do |county, index|
    puts "#{index+1}. #{county[0]}"
  end

  input = STDIN.gets.chomp.to_i
  county = counties.keys[input - 1]
  if county
    journeys = Journey.joins(:neighborhood_a).where("neighborhoods.county = ? and journeys.trip_duration is null", county)
    journeys_count = journeys.count
    puts "This will seed data from the Google Maps API for #{journeys_count} routes. Continue? [y/n]\n"
    if STDIN.gets.chomp.downcase == "y"
      counter = 1
      journeys.each do |journey|
        # try public transit
        duration = journey.get_trip_duration("TRANSIT")
        # then driving
        if !duration
          duration = journey.get_trip_duration("DRIVING")
        end
        # then by zip...
        if !duration
          duration = journey.get_trip_duration_by_zip("TRANSIT")
        end
        
        if duration
          journey.trip_duration = duration
          journey.save
        end
        print "\rSeeded #{counter} of #{journeys_count}"
        counter += 1
      end
      puts "\nDone seeding routes."
    end
  end
end
