module SodaApi
  APP = Rails.application.credentials.soda[:app_token]
  SECRET = Rails.application.credentials.soda[:secret_token]

  class Nyc311Client
    API_ENDPOINT = "data.cityofnewyork.us"
    RESOURCE = "fhrw-4uyv"
  
    def most_recent_incident
      get_request({
        "$limit" => "1",
        "$order" => "created_date DESC"
      }).first
    end

    def results_after_date(date)
      get_request({
        "$where" => "created_date > '#{format_date(date)}'",
        "$order" => "created_date"
      })
    end 
    
    private

    def client
      SODA::Client.new({
        domain: API_ENDPOINT, 
        app_token: APP
      })
    end

    def get_request(params)
      client.get(RESOURCE, params)
    end

    def format_date(date)
      date.strftime('%Y-%m-%dT%H:%M:%S')
    end

  end

end