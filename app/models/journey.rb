class Journey < ApplicationRecord
  belongs_to :neighborhood_a, class_name: "Neighborhood"
  belongs_to :neighborhood_b, class_name: "Neighborhood"

  scope :within_acceptable_duration, -> (origin_id, duration_minutes) { 
    where("neighborhood_a_id = ? and transit_trip_duration < ?", origin_id, (duration_minutes * 60)) 
  }

  scope :within_acceptable_duration_reverse, -> (origin_id, duration_minutes) { 
    where("neighborhood_b_id = ? and transit_trip_duration < ?", origin_id, (duration_minutes * 60)) 
  }

  def get_trip_duration(mode)
    api_client = GoogleApi::MapsClient.new
    origin = self.neighborhood_a.center_latitude_longitude_string
    destination = self.neighborhood_b.center_latitude_longitude_string
    response_json = api_client.get_directions(origin, destination, mode)
    result_time = nil
    if response_json && response_json["status"] != "ZERO_RESULTS"
      result_time = response_json["routes"][0]["legs"][0]["duration"]["value"]
    end
    result_time
  end

  def get_trip_duration_by_zip(mode)
    api_client = GoogleApi::MapsClient.new
    origin = self.neighborhood_a.random_zip || self.neighborhood_a.center_latitude_longitude_string
    destination = self.neighborhood_b.random_zip || self.neighborhood_b.center_latitude_longitude_string
    response_json = api_client.get_directions(origin, destination, mode)
    result_time = nil
    if response_json && response_json["status"] != "ZERO_RESULTS"
      result_time = response_json["routes"][0]["legs"][0]["duration"]["value"]
    end
    result_time
  end

end
