module GoogleApiCommunicator

  APP = Rails.application.credentials.google[:api_key]

  def trip_duration(origin, destination)
    string = RestClient.get("https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{APP}")
    hash = JSON.parse(string)
    hash["routes"][0]["legs"][0]["duration"]["value"]
  end

  def mins_to_seconds(mins)
    mins *= 60
  end

  def validate_address(origin)
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

  def geocode(origin)
    string = RestClient.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{origin}&key=#{APP}")
    hash = JSON.parse(string)
  end

  def create_new_array_of_zips(origin, ideal_duration_in_seconds, array_of_zips)
    valid_zips = []
    array_of_zips.each do |zip|
      valid_zips << zip if trip_duration(origin, zip) <= ideal_duration_in_seconds
    end
    valid_zips
  end

  def validate_zip(origin, ideal_duration, array_of_zips)
    ideal_duration_in_seconds = mins_to_seconds(ideal_duration)
    results = ""
    if validate_address(origin)
      results = create_new_array_of_zips(origin, ideal_duration_in_seconds, array_of_zips)
      if results.count == 0
        results = "NO ZIPS FOUND - INCREASE COMMUTE TIME"
      end
    else
      results = "ERROR IN USER INPUT"
    end
    results
  end

end # end of module
