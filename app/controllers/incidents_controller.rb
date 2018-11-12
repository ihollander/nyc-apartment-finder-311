class IncidentsController < ApplicationController

  def index
    zips = Incident.select(:zip).distinct.limit(20).map(&:zip) # change this to take from search criteria (distance allowed)
    @cities = Incident.select(:)

  end

end
