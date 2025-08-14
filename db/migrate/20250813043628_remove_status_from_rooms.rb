class RemoveStatusFromRooms < ActiveRecord::Migration[7.0]
  def change
    remove_column :rooms, :status, :integer
  end
end
