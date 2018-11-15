class AddBoroughNameToNeighborhoods < ActiveRecord::Migration[5.2]
  def change
    add_column :neighborhoods, :borough, :string
  end
end
