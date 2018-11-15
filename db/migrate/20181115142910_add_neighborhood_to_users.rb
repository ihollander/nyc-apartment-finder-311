class AddNeighborhoodToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :neighborhood_id, :integer
    add_index :users, :neighborhood_id
  end
end
