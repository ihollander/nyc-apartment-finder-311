require 'active_support/core_ext/hash'  #from_xml
require 'nokogiri'
require 'rest-client'
require 'pry'


APP = "X1-ZWz189leskvfnv_7zykg"

def array_of_addresses(neighbourhood, array_of_zips)
  array = []
  array_of_addresses_by_zips = api_hash(neighbourhood, array_of_zips)
  array_of_addresses_by_zips.each do |hash|
    hash["searchresults"]["response"]["results"]["result"].each do |r|
      binding.pry
      array << r["address"]
    end
  end
  array
end

def api_request(neighbourhood, zip)
  response = RestClient.get("http://www.zillow.com/webservice/GetSearchResults.htm?zws-id=#{APP}&address=#{neighbourhood}&citystatezip=#{zip}")
  doc = Nokogiri::XML(response)
  hash = Hash.from_xml(doc.to_s)
end

def api_hash(neighbourhood, array_of_zips)
  array_of_addresses_by_zips = []
  array_of_zips.each do |zip|
    hash = api_request(neighbourhood, zip)
    if validate_response(hash).class == "String"
      puts  "error"
    end
    array_of_addresses_by_zips << hash
  end
  array_of_addresses_by_zips
end

def validate_response(response)
  response_code = response["searchresults"]["message"]["code"]
  response_message = response["searchresults"]["message"]["text"]
  validation_logic(response_code, response_message)
end

def validation_logic(code, message)
  response_status = false
  if code == "508" || code == "507"
    "Error: no exact match found for input address"
  elsif code == "508" || code == "507"
    "Failed to resolve city/state (or zip code). message: #{message}"
  elsif code == "3" || code == "4" || code == "505"
    "The Zillow API is currently unavailable"
  elsif code == "1"
    "Service error: #{message}"
  elseif code == "2"
    "Invalid Zillow API key"
  elsif code == "0"
    "Request successfully processed"
    response_status = true
  end
end


array_of_addresses("financial district", [10005])
# rails g resource apartment street zipcode city state latitude:float longitude:float url zillow_id:integer value:integer price_change:boolean
