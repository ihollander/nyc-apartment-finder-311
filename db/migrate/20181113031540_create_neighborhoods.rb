class CreateNeighborhoods < ActiveRecord::Migration[5.2]
  def change
    create_table :neighborhoods do |t|
      t.string :name
      t.string :county
      t.string :regionid
      t.multi_polygon :geom, :srid => 4326

      t.timestamps
    end
  end
end
