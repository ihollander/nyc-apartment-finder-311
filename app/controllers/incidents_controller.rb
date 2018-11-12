class IncidentsController < ApplicationController
  before_action :set_criteria_options, only: %i[search]
  before_action :set_minute_options, only: %i[index]

  # starting page for filtering distance
  def index
  end

  # page for filtering incidents
  def search
    # zips = get from api(params["search"]["address"], params["search"]["minutes"])
    zips = Incident.select(:zip).distinct.limit(20).map(&:zip) # change this to take from search criteria (distance allowed)
    @cities = Incident.select(:city).order(:city).distinct.where(:zip => zips).map(&:city)
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
        count_incidents = case criterion
          when "Noise Pollution" then count_incidents = incidents.noise_pollution.count
          when "Sanitation" then incidents.bad_sanitation.count
          when "Food Safety" then incidents.food_safety.count
        end
        { 
          criterion: criterion, 
          incidents: count_incidents 
        }
      end
    end
  end

  private

  def set_criteria_options
    @criteria_options = ["Noise Pollution", "Sanitation", "Food Safety"]
  end

  def set_minute_options
    @minute_options = [15,30,45,60]
  end
end
