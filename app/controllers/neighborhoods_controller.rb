class NeighborhoodsController < ApplicationController
  before_action :set_criteria_options, only: %i[search]
  before_action :set_minute_options, only: %i[index]
  before_action :current_user, only: :index

  # starting page for filtering distance
  def index
    @default_address = @user.work_address
  end

  # page for filtering incidents
  def search
    @address = params["search"]["address"]
    @minutes = params["search"]["minutes"].to_i
    # find neighborhood for address (origin)
    # TODO: handle errors
    origin = Neighborhood.find_by_address(@address)
    # check journeys table for journeys matching neighborhood_a -> and neighborhood_b <-
    # TODO: handle errors
    neighborhood_ids = Journey.within_acceptable_duration(origin.id, @minutes).map(&:neighborhood_b_id)
    neighborhood_ids += Journey.within_acceptable_duration_reverse(origin.id, @minutes).map(&:neighborhood_a_id)
    @neighborhoods = Neighborhood.find(neighborhood_ids).uniq
  end

  # page for displaying results
  def result
    byebug
    @criteria = params["search"]["criteria"].reject{ |n| n.empty? }
    neighborhood_ids = params["search"]["neighborhoods"].reject{ |n| n.empty? }
    @neighborhoods = Neighborhood.find(neighborhood_ids)
  end

  private

  def set_criteria_options
    @criteria_options = Incident.criteria_hash.keys.sort
  end

  def set_minute_options
    @minute_options = [15,30,45,60]
  end
end
