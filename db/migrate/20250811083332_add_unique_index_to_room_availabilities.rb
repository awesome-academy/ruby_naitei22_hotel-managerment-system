class AddUniqueIndexToRoomAvailabilities < ActiveRecord::Migration[7.0]
  def change
    add_index :room_availabilities, [:room_id, :available_date], unique: true
  end
end
