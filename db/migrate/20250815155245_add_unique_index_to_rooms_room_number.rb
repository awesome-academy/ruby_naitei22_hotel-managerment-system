class AddUniqueIndexToRoomsRoomNumber < ActiveRecord::Migration[7.0]
  def change
    add_index :rooms, :room_number, unique: true
  end
end
