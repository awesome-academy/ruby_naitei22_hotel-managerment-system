class AddUniqueIndexToRoomTypeName < ActiveRecord::Migration[7.0]
  def change
    add_index :room_types, :name, unique: true
  end
end
