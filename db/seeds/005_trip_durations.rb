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
    journeys = Journey.joins(:neighborhood_a).joins(:neighborhood_b).where("neighborhoods.county = ? and neighborhood_bs_journeys.county = ? and journeys.trip_duration is null", county, county)
    puts "This will seed data from the Google Maps API for #{journeys.count} routes. Continue? [y/n]"
    if STDIN.gets.chomp.downcase == "y"
      journeys.sample(5).each do |journey|
        duration = journey.get_trip_duration
        journey.trip_duration = duration
        journey.save
      end
    end
  end
end
