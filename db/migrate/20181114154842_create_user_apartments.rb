class CreateUserApartments < ActiveRecord::Migration[5.2]
  def change
    create_table :user_apartments do |t|
      t.references :user, foreign_key: true
      t.references :apartment, foreign_key: true

      t.timestamps
    end
  end
end
