class CreateJourneys < ActiveRecord::Migration[5.2]
  def change
    create_table :journeys do |t|
      t.integer :neighborhood_a_id
      t.integer :neighborhood_b_id
      t.integer :trip_duration

      t.timestamps
    end

    add_index :journeys, :neighborhood_a_id
    add_index :journeys, :neighborhood_b_id
    add_index :journeys, [:neighborhood_a_id, :neighborhood_b_id], unique: true

  end
end
