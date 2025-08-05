class CreateRoomAvailabilities < ActiveRecord::Migration[7.0]
  def change
    create_table :room_availabilities do |t|
      t.references :room, null: false, foreign_key: true
      t.date :available_date
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
