class CreateRoomAvailabilityRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :room_availability_requests do |t|
      t.references :room_availability, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
