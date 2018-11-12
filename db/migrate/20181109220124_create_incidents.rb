class CreateIncidents < ActiveRecord::Migration[5.2]
  def change
    create_table :incidents do |t|
      t.belongs_to :complaint, foreign_key: true
      t.belongs_to :agency, foreign_key: true
      t.belongs_to :borough, foreign_key: true
      t.datetime :date_opened
      t.datetime :date_closed
      t.string :descriptor
      t.float :latitude
      t.float :longitude
      t.boolean :status
      t.string :zip
      t.string :incident_address
      t.string :city

      t.timestamps
    end
  end
end
