class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.references :request, null: false, foreign_key: true
      t.string :full_name
      t.integer :identity_type
      t.string :identity_number
      t.date :identity_issued_date
      t.string :identity_issued_place

      t.timestamps
    end
  end
end
