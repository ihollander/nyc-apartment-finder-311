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

  end # end of MapsClient

end # end of module
