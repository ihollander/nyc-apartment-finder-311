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

  def commute_time(origin_neighborhood_id)
    journey = Journey.find_by(neighborhood_a_id: self.id, neighborhood_b_id: origin_neighborhood_id) || Journey.find_by(neighborhood_b_id: self.id, neighborhood_a_id: origin_neighborhood_id)
    journey.trip_duration / 60
  end

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

  def random_zip
    self.incidents.count > 0 ? self.incidents.sample.zip : nil
  end

  # read geojson string and add properties for heatmap
  def geojson
    "/geojson/neighborhood_id_#{self.id}.json"
  end

  def static_map_url
    base_url = "https://maps.googleapis.com/maps/api/staticmap?"
    enc = Polylines::Encoder.encode_points(self.geom_array)
    params = {
      center: center_latitude_longitude_string,
      zoom: "13",
      size: "300x300",
      key: Rails.application.credentials.google[:api_key]
    }
    base_url + params.to_query + '&path=fillcolor:0xAA000033%7Ccolor:0xFFFFFF00%7Cenc:' + enc
  end

  # converts geom multipolygon to array of lat long points
  def geom_array
    factory = RGeo::GeoJSON::EntityFactory.instance
    feature = factory.feature self.geom
    hash = RGeo::GeoJSON.encode feature
    hash["geometry"]["coordinates"][0][0]
  end

end
