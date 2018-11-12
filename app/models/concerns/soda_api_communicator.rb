module SodaApiCommunicator
  APP = Rails.application.credentials.soda[:app_token]
  SECRET = Rails.application.credentials.soda[:secret_token]

  class ThreeOneOne
    attr_reader :client, :date_format, :resource
    
    def initialize
      @client = SODA::Client.new({
        domain: "data.cityofnewyork.us", 
        app_token: APP
      })
      @date_format = '%Y-%m-%dT%H:%M:%S'
      @resource = "fhrw-4uyv"
    end

    def most_recent_incident
      self.client.get(self.resource, {
        "$limit" => "1",
        "$order" => "created_date DESC"
      }).first
    end

    def results_after_date(date)
      date_string = date.strftime(self.date_format)
      self.client.get(self.resource, {
        "$where" => "created_date > '#{date_string}'",
        "$order" => "created_date"
      })
    end  
  end

end