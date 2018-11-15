class AddPropertiesToApartments < ActiveRecord::Migration[5.2]
  def change
    add_column :apartments, :sqft, :integer
    add_column :apartments, :bathrooms, :integer
    add_column :apartments, :bedrooms, :integer
    add_column :apartments, :year_built, :integer
    add_column :apartments, :images, :string, default: [], array: true
    add_column :apartments, :description, :string
    add_column :apartments, :neighborhood_id, :integer
  end
end