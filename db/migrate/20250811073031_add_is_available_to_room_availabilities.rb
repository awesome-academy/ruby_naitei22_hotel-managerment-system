class AddIsAvailableToRoomAvailabilities < ActiveRecord::Migration[7.0]
  def change
    add_column :room_availabilities, :is_available, :boolean, default: true, null: false
  end
end
