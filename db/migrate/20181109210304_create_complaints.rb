class CreateComplaints < ActiveRecord::Migration[5.2]
  def change
    create_table :complaints do |t|
      t.string :name
      t.references :agency, foreign_key: true

      t.timestamps
    end
  end
end
