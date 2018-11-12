class Incident < ApplicationRecord
  belongs_to :complaint
  belongs_to :agency
  belongs_to :borough

  acts_as_mappable  default_units: :meters,
                    lat_column_name: :latitude,
                    lng_column_name: :longitude

  # match criteria names (for dropdowns) to scope function names
  def self.criteria_hash
    {
      "Noise Pollution" => :criteria_hash, 
      "Sanitation" => :noise_pollution, 
      "Food Safety" => :food_safety,
      "Death Sentence (hazardous materials)" => :death_sentence,
      "Bad Neighbors" => :bad_neighbors,
      "Hip Neighborhood" => :hip_neighborhood,
      "Air Quality" => :air_quality,
      "Neighborhood Aesthetics" => :neighborhood_aesthetics,
      "Utility Quality" => :utility_quality
    }
  end

  # scopes for easy querying!
  scope :by_zips, -> (zips) { where(zip: zips) }
  scope :by_city, -> (city) { where(city: city) }
  scope :bad_sanitation, -> { joins(:complaint).where(complaints: { name: ["Rodent", "Unsanitary Pigeon Condition", "Overflowing Litter Baskets", "Sewer", "UNSANITARY CONDITION"] } ) }
  scope :noise_pollution, -> { joins(:complaint).where("complaints.name LIKE ?", "%Noise%") }
  scope :food_safety, -> { joins(:complaint).where("complaints.name = ?", "Food Poisoning") }
  scope :death_sentence, -> { joins(:complaint).where(complaints: { name: ["Lead", "Radioactive Material", "Asbestos", "Hazardous Materials", "Industrial Waste", "Mold"] } ) }
  scope :bad_neighbors, -> { joins(:complaint).where(complaints: { name: ["Blocked Driveway", "Illegal Parking", "Noise", "Animal Abuse", "Drug Activity", "Illegal Fireworks", "Harboring Bees/Wasps"] } ) }
  scope :hip_neighborhood, -> { joins(:complaint).where(complaints: { name: ["Graffiti", "Smoking", "Drug Activity", "Illegal Animal Kept as Pet", "Bike/Roller/Skate Chronic", "Beach/Pool/Sauna Complaint", "Tattooing"] } ) }
  scope :air_quality, -> { joins(:complaint).where(complaints: { name: ["Smoking"] } ) }
  scope :neighborhood_aesthetics, -> { joins(:complaint).where(complaints: { name: ["PAINT/PLASTER", "Street Light Condition"] } ) }
  scope :utility_quality, -> { joins(:complaint).where(complaints: { name: ["HEAT/HOT WATER", "General Construction/Plumbing", "Sewer", "WATER LEAK", "Water System", "ELECTRIC"] } ) }
  
  # returns an array of city names as strings
  def self.get_cities_from_zips(zips)
    self.by_zips(zips).select(:city).order(:city).distinct.map(&:city)
  end

  # returns an array of city names as strings
  def self.get_unique_zips
    zips = self.select(:zip).order(:zip).distinct.map(&:zip)
    parsed_zips = zips.select do |zip|
      zip && zip != "N/A" && zip != "0"
    end
    parsed_zips.sample(20)
  end

  def self.check_zips_from_api(zips)

  end

  # takes CSV row, parses data and saves to new Incident
  def self.create_from_csv_row(row, date_format)
    agency = Agency.find_or_create_by(name: row["Agency Name"])
    borough = Borough.find_or_create_by(name: row["Borough"])
    complaint = Complaint.find_or_create_by(name: row["Complaint Type"])
    date_opened_parsed = row["Created Date"] ? DateTime.strptime(row["Created Date"], date_format) : nil
    date_closed_parsed = row["Closed Date"] ? DateTime.strptime(row["Closed Date"], date_format) : nil
    parsed_zip = row["Incident Zip"] && row["Incident Zip"].length > 5 ? row["Incident Zip"][0..4] : row["Incident Zip"]
    incident_hash = {
      agency: agency,
      borough: borough,
      complaint: complaint,
      date_opened: date_opened_parsed,
      date_closed: date_closed_parsed,
      descriptor: row["Descriptor"],
      latitude: row["Latitude"] ? row["Latitude"].to_f : nil,
      longitude: row["Longitude"] ? row["Longitude"].to_f : nil,
      status: row["Status"] == "Open",
      zip: parsed_zip,
      incident_address: row["Incident Address"],
      city: row["City"] ? row["City"].upcase : nil
    }
    self.create(incident_hash)
  end
  
  # takes API data as Hashie, parses data and saves to new Incident
  def self.create_from_api(api_hash, date_format)
    agency = Agency.find_or_create_by(name: api_hash.agency_name)
    borough = Borough.find_or_create_by(name: api_hash.borough)
    complaint = Complaint.find_or_create_by(name: api_hash.complaint_type)
    date_opened_parsed = api_hash.created_date ? DateTime.strptime(api_hash.created_date, date_format) : nil
    date_closed_parsed = api_hash.closed_date ? DateTime.strptime(api_hash.closed_date, date_format) : nil
    parsed_zip = api_hash.incident_zip && api_hash.incident_zip.length > 5 ? api_hash.incident_zip[0..4] : api_hash.incident_zip
    incident_hash = {
      agency: agency,
      borough: borough,
      complaint: complaint,
      date_opened: date_opened_parsed,
      date_closed: date_closed_parsed,
      descriptor: api_hash.descriptor,
      latitude: api_hash.latitude ? api_hash.latitude.to_f : nil,
      longitude: api_hash.longitude ? api_hash.longitude.to_f : nil,
      status: api_hash.status == "Open",
      zip: parsed_zip,
      incident_address: api_hash.incident_address,
      city: api_hash.city ? api_hash.city.upcase : nil
    }
    self.create(incident_hash)
  end
end
