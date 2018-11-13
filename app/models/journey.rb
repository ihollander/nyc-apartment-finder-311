class Journey < ApplicationRecord
  belongs_to :neighborhood_a, class_name: "Neighborhood"
  belongs_to :neighborhood_b, class_name: "Neighborhood"

  def get_trip_duration
    api_client = GoogleApi::MapsClient.new
    origin = self.neighborhood_a.center_latitude_longitude_string
    destination = self.neighborhood_b.center_latitude_longitude_string
    response_json = api_client.get_directions(origin, destination)
    response_json["routes"][0]["legs"][0]["duration"]["value"]
  end
end
