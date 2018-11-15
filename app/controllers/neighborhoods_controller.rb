class NeighborhoodsController < ApplicationController
  before_action :set_criteria_options, only: :index
  before_action :current_user, only: [:index, :result]

  # starting page for filtering distance
  def index
    neighborhood_ids = Journey.within_acceptable_duration(@user.neighborhood_id, @user.commute_time).map(&:neighborhood_b_id)
    neighborhood_ids += Journey.within_acceptable_duration_reverse(@user.neighborhood_id, @user.commute_time).map(&:neighborhood_a_id)
    if neighborhood_ids.count > 0 then
      @neighborhoods = Neighborhood.order(:name).find(neighborhood_ids).uniq
    else
      flash[:error] = "No routes match"
    end
  end

  # page for displaying results
  def result
    @criteria = params["search"]["criteria"].reject{ |n| n.empty? }
    neighborhood_ids = params["search"]["neighborhoods"].reject{ |n| n.empty? }
    @neighborhoods = Neighborhood.find(neighborhood_ids)
    # sort by commute time
    @neighborhoods = @neighborhoods.sort_by do |n|
      n.commute_time(@user.neighborhood_id)
    end
  end

  private

  def set_criteria_options
    @criteria_options = Incident.criteria_hash.keys.sort
  end

end
