class CreateApartments < ActiveRecord::Migration[5.2]
  def change
    create_table :apartments do |t|
      t.string :street
      t.string :zipcode
      t.string :city
      t.string :state
      t.float :latitude
      t.float :longitude
      t.string :url
      t.integer :zillow_id
      t.integer :value
      t.boolean :price_change
      t.integer :sqft
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :year_built
      t.string :images, array: true, default: []
      t.string :description
      t.integer :neighborhood_id

      t.timestamps
    end
  end
end
