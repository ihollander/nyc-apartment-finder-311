class Journey < ApplicationRecord
  belongs_to :neighborhood_a, class_name: "Neighborhood"
  belongs_to :neighborhood_b, class_name: "Neighborhood"

  scope :within_acceptable_duration, -> (origin_id, duration_minutes) { 
    where("neighborhood_a_id = ? and trip_duration < ?", origin_id, (duration_minutes * 60)) 
  }

  def get_trip_duration
    api_client = GoogleApi::MapsClient.new
    origin = self.neighborhood_a.center_latitude_longitude_string
    destination = self.neighborhood_b.center_latitude_longitude_string
    response_json = api_client.get_directions(origin, destination)
    result_time = nil
    if response_json && response_json["status"] != "ZERO_RESULTS"
      result_time = response_json["routes"][0]["legs"][0]["duration"]["value"]
    else
      response_json = api_client.get_directions(origin, destination, "DRIVING")
      if response_json && response_json["status"] != "ZERO_RESULTS"
        result_time = response_json["routes"][0]["legs"][0]["duration"]["value"]
      end
    end
    result_time
  end

end
