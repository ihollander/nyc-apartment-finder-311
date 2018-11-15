class AddCommuteTimeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :commute_time, :integer, default: 15
  end
end
