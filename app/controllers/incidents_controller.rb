class IncidentsController < ApplicationController
  before_action :set_criteria_options, only: %i[search]
  before_action :set_minute_options, only: %i[index]

  # starting page for filtering distance
  def index
  end

  # page for filtering incidents
  def search
    address = params["search"]["address"]
    minutes = params["search"]["minutes"].to_i
    # find neighborhood for address (origin)
    origin = Neighborhood.find_by_address(address)
    # check journeys table for journeys matching neighborhood_a
    journeys = Journey.within_acceptable_duration(origin.id, minutes).neighborhood_b.map(&:name)
  end

  # page for displaying results
  def result
    # params["search"] = {"cities"=>["COLLEGE POINT", "GLEN OAKS"], "criteria"=>"Pollution"}
    cities = params["search"]["cities"]
    criteria = params["search"]["criteria"]
    @result_hash = {}
    cities.each do |city|
      incidents = Incident.by_city(city)
      @result_hash[city] = criteria.map do |criterion|
        # average by neighborhood? or start at a certain number and + or - points for each condition
        scope_method = Incident.criteria_hash[criterion]
        count_incidents = incidents.send(scope_method).count
        { 
          criterion: criterion, 
          incidents: count_incidents 
        }
      end
    end
  end

  private

  def set_criteria_options
    @criteria_options = Incident.criteria_hash.keys.sort
  end

  def set_minute_options
    @minute_options = [15,30,45,60]
  end
end
