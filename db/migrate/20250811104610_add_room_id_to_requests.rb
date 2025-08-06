class AddRoomIdToRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :requests, :room, null: false, foreign_key: true
  end
end
