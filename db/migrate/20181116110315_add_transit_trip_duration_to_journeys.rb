class AddTransitTripDurationToJourneys < ActiveRecord::Migration[5.2]
  def change
    add_column :journeys, :transit_trip_duration, :integer
  end
end
