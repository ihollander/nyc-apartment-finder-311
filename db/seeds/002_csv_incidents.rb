# Seed initial data from CSV
# Deletes all data first to prevent duplication
puts "Import/overwrite CSV data? This will take a while. [y/n]"
if STDIN.gets.chomp.downcase == "y"
  puts "Destroying incidents..."
  Incident.destroy_all
  puts "Destroying complaints..."
  Complaint.destroy_all
  puts "Destroying agencies..."
  Agency.destroy_all
  
  csv_path = './db/csv_data/311.csv'

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