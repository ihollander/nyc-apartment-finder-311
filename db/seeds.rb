require 'csv'

# Seed initial data from CSV
# Deletes all data first to prevent duplication
puts "Overwrite existing database with CSV data? This will take a while. [y/n]"
if STDIN.gets.chomp.downcase == "y"
  puts "Destroying incidents..."
  Incident.destroy_all
  puts "Destroying complaints..."
  Complaint.destroy_all
  puts "Destroying agencies..."
  Agency.destroy_all
  puts "Destroying boroughs..."
  Borough.destroy_all

  csv_path = './storage/311.csv'

  puts "Calculating CSV rows..."
  total = CSV.foreach(csv_path, headers: true).count

  puts "Seeding incidents...\n"
  row_number = 1
  CSV.foreach(csv_path, headers: true) do |row|
    Incident.create_from_csv_row(row, '%m/%d/%Y %I:%M:%S %p')
    print "Incidents #{row_number} of #{total} seeded\r" if row_number % 100 == 0
    row_number += 1
  end
  puts "\nIncidents seeded!"
end

# call API and parse data from calls after CSV data was seeded...
# move this to a job that runs every X hours to update our dataset?
# problem is if any incident gets updated, this isn't reflected in our data
puts "Check API for additional incidents? [y/n]"

if STDIN.gets.chomp.downcase == "y"
  # check most recent incident in the API
  puts "Connecting to API..."
  api = SodaApiCommunicator::ThreeOneOne.new
  api_most_recent = api.most_recent_incident
  puts "API   | Most recent incident: #{api_most_recent.created_date}"
  
  # format string as data to compare against date in database
  last_incident_date_api = DateTime.strptime(api_most_recent.created_date, api.date_format) # 2018-11-11T02:14:06.000

  # check most recent incident in our database
  last_incident_date = Incident.order(date_opened: :desc).first.date_opened
  puts "LOCAL | Most recent incident: #{last_incident_date.strftime(api.date_format)}"

  # call API until our database has most recent info
  puts "Seeding from API..."
  while last_incident_date < last_incident_date_api
    puts "\nCalling API..."
    api_response = api.results_after_date(last_incident_date) # 
    puts "#{api_response.length} results returned from API, starting from #{api_response.first.created_date}\n"
    row_number = 1
    api_response.each do |incident_hash|
      Incident.create_from_api_hash(incident_hash, api.date_format)
      print "Incidents #{row_number} of #{api_response.length} seeded\r" if row_number % 100 == 0
      row_number += 1
    end
    last_incident_date = Incident.order(date_opened: :desc).first.date_opened
  end
end