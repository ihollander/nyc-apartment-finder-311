class Neighborhood < ApplicationRecord
  has_many :incidents
  has_many :searches
  has_many :users, through: :searches
  has_many :journeys_a, class_name: "Journey", foreign_key: "neighborhood_a_id"
  has_many :journeys_b, class_name: "Journey", foreign_key: "neighborhood_b_id"

  scope :find_by_lonlat, -> (longitude, latitude) { 
    where(%{ 
      ST_Within(ST_SetSRID(ST_MakePoint(%f, %f),4326), geom) 
    } % [longitude, latitude])
  }

  def self.find_by_address(address)
    api_client = GoogleApi::MapsClient.new
    json_response = api_client.geocode(address)
    # get lat and long as floats
    lat = json_response["results"][0]["geometry"]["location"]["lat"]
    lng = json_response["results"][0]["geometry"]["location"]["lng"]
    self.find_by_lonlat(lng, lat).first
  end

  def center_latitude
    self.geom.centroid.y
  end

  def center_longitude
    self.geom.centroid.x
  end

  def center_latitude_longitude_string
    "#{self.center_latitude}, #{self.center_longitude}"
  end

end
