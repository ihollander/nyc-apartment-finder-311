class NeighborhoodsController < ApplicationController
  before_action :set_criteria_options, only: :index
  before_action :current_user, only: [:index, :result]

  # starting page for filtering distance
  def index
    neighborhood_ids = Journey.within_acceptable_duration(@user.neighborhood_id, @user.commute_time).map(&:neighborhood_b_id)
    neighborhood_ids += Journey.within_acceptable_duration_reverse(@user.neighborhood_id, @user.commute_time).map(&:neighborhood_a_id)
    if neighborhood_ids.count > 0 then
      @neighborhoods = Neighborhood.find(neighborhood_ids).uniq
      @neighborhoods.sort_by! { |n| n.name_with_borough }
    else
      flash[:error] = "No routes match"
    end
  end

  def show
    @neighborhood = Neighborhood.find_by(id: params[:id])
    @complaint_types = Complaint.joins(:incidents).order("count_complaints_name DESC").where("neighborhood_id = ?", @neighborhood.id).select("complaints.name").group("complaints.name").count
  end

  # page for displaying results
  def result
    @criteria = params["search"]["criteria"].reject{ |n| n.empty? }
    neighborhood_ids = params["search"]["neighborhoods"].reject{ |n| n.empty? }
    if @criteria.count < 3 || neighborhood_ids.count < 3
      flash[:errors] = ["Please select at least three neighborhoods and three criteria."]
      redirect_to neighborhoods_path
    else
      @neighborhoods = Neighborhood.find(neighborhood_ids)
      # sort by commute time
      @neighborhoods = @neighborhoods.sort_by do |n|
        n.commute_time(@user.neighborhood_id)
      end
      # this logic should be somewhere else... view model?
      @criteria_hash = {}
      @neighborhoods.each do |neighborhood|
        @criteria_hash["#{neighborhood.id}"] = {
          criteria: []
        }
        @criteria.each do |criteria|
          scope_method = Incident.criteria_hash[criteria.to_sym]["method"]
          incidents = neighborhood.incidents.send(scope_method)
          max_incidents = Incident.joins(:neighborhood).select("neighborhoods.name").send(scope_method).group("neighborhoods.name").count.max_by { |k,v| v }[1]
          incident_percentage = (1 - (incidents.count.to_f / max_incidents)) * 100
          @criteria_hash["#{neighborhood.id}"][:criteria] << {
            name: criteria,
            alias: Incident.criteria_hash[criteria.to_sym]["show_alias"],
            incidents: incidents.count,
            max_incidents: max_incidents,
            incident_percentage: incident_percentage
          }
        end
        percentages = @criteria_hash["#{neighborhood.id}"][:criteria].collect{ |p| p[:incident_percentage] }
        match_percentage = (percentages.reduce(:+) / percentages.count).to_i
        @criteria_hash["#{neighborhood.id}"][:match_percentage] = match_percentage
      end
    end
  end

  private

  def set_criteria_options
    @criteria_options = Incident.criteria_hash.keys.sort
  end

end
