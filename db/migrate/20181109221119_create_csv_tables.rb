class CreateCsvTables < ActiveRecord::Migration[5.2]
  def change
    create_table :csv_tables do |t|
      t.string :agency_name
      t.string :borough
      t.string :closed_date
      t.string :complaint_type
      t.string :created_date
      t.string :descriptor
      t.string :latitude
      t.string :longitude
      t.string :status
      t.string :resolution_description

      t.timestamps
    end
  end
end
