class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :room_number
      t.references :room_type, null: false, foreign_key: true
      t.integer :status
      t.text :description
      t.integer :capacity
      

      t.timestamps
    end
  end
end
