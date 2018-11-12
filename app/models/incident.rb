class Incident < ApplicationRecord
  belongs_to :complaint
  belongs_to :agency
  belongs_to :borough

  acts_as_mappable  default_units: :meters,
                    lat_column_name: :latitude,
                    lng_column_name: :longitude

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
      city: row["City"]
    }
    self.create(incident_hash)
  end
  
  def self.create_from_api(api_hash, date_format)
    agency = Agency.find_or_create_by(name: api_hash.agency_name)
    borough = Borough.find_or_create_by(name: api_hash.borough)
    complaint = Complaint.find_or_create_by(name: api_hash.complaint_type)
    date_opened_parsed = api_hash.created_date ? DateTime.strptime(api_hash.created_date, date_format) : nil
    date_closed_parsed = api_hash.closed_date ? DateTime.strptime(api_hash.closed_date, date_format) : nil
    parsed_zip = api_hash.incident_zip.length > 5 ? api_hash.incident_zip[0..4] : api_hash.incident_zip
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
      city: api_hash.city
    }
    self.create(incident_hash)
  end
end
