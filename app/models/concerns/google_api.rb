module GoogleApi
  API_KEY = Rails.application.credentials.google[:api_key]
  
  class MapsClient
    API_URL = "https://maps.googleapis.com"

    def get_directions(origin, destination)
      request(
        http_method: :get,
        endpoint: "/maps/api/directions/json",
        params: {
          key: API_KEY,
          origin: origin,
          destination: destination
        }
      )
    end

    def geocode(origin)
      request(
        http_method: :get,
        endpoint: "/maps/api/geocode/json",
        params: {
          key: API_KEY,
          address: origin
        }
      )
    end

    private

    def client
      Faraday.new(API_URL) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter
      end
    end

    def request(http_method:, endpoint:, params: {})
      response = client.public_send(http_method, endpoint, params)
      Oj.load(response.body)
    end

    def self.validate_zip(origin, ideal_duration, array_of_zips)
      ideal_duration_in_seconds = mins_to_seconds(ideal_duration)
      results = ""
      if validate_address(origin)
        results = create_new_array_of_zips(origin, ideal_duration_in_seconds, array_of_zips)
        if results.count == 0
          results = "NO ZIPS FOUND - PLEASE SPECIFY A NY ADDRESS"
        end
      else
        results = "ERROR IN USER INPUT"
      end
      results
    end
    
    def self.trip_duration(origin, destination)
      puts "Calling api for #{destination}..."
      string = RestClient.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{APP}")
      hash = JSON.parse(string)
      hash["routes"][0]["legs"][0]["duration"]["value"]
    end
  
    def self.mins_to_seconds(mins)
      mins *= 60
    end
  
    def self.validate_address(origin)
      hash = geocode(origin)
      result = []
      answer = ""
      if hash["results"].count != 0
        hash["results"][0]["address_components"].find do |h|
          result << true if h["short_name"].include?("NY")
        end
      else
        answer = false
      end
      if result[0] == true
        answer = true
      end
      answer
    end
  
    def self.geocode(origin)
      string = RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{origin}&key=#{APP}")
      hash = JSON.parse(string)
    end
  
    def self.create_new_array_of_zips(origin, ideal_duration_in_seconds, array_of_zips)
      valid_zips = []
      array_of_zips.each do |zip|
        valid_zips << zip if trip_duration(origin, zip) <= ideal_duration_in_seconds
      end
      valid_zips
    end
  end

end # end of module
