# call API and parse data from calls after CSV data was seeded...
# move this to a job that runs every X hours to update our dataset?
# problem is if any incident gets updated, this isn't reflected in our data
puts "Check API for additional incidents? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  # check most recent incident in the API
  puts "Connecting to API..."
  date_format = '%Y-%m-%dT%H:%M:%S'
  soda_client = SodaApi::Nyc311Client.new
  api_most_recent = soda_client.most_recent_incident
  puts "API   | Most recent incident: #{api_most_recent.created_date}"
  
  # format string as data to compare against date in database
  last_incident_date_api = DateTime.strptime(api_most_recent.created_date, date_format) # 2018-11-11T02:14:06.000

  # check most recent incident in our database
  last_incident_date = Incident.order(date_opened: :desc).first.date_opened
  puts "LOCAL | Most recent incident: #{last_incident_date.strftime(date_format)}"

  # call API until our database has most recent info
  while last_incident_date < last_incident_date_api
    puts "\nCalling API..."
    api_response = soda_client.results_after_date(last_incident_date)
    puts "#{api_response.length} results returned from API, starting from #{api_response.first.created_date}\n"
    row_number = 1
    api_response.each do |incident_hash|
      Incident.create_from_api(incident_hash, date_format)
      print "Incidents #{row_number} of #{api_response.length} seeded\r" if row_number % 100 == 0
      row_number += 1
    end
    last_incident_date = Incident.order(date_opened: :desc).first.date_opened
  end
  puts "API seeding done!"
end