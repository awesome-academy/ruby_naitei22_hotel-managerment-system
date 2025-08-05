class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.references :booking, null: false, foreign_key: true
      t.datetime :check_in
      t.datetime :check_out
      t.integer :number_of_guests
      t.integer :status
      t.text :note

      t.timestamps
    end
  end
end
