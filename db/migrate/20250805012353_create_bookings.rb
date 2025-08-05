class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.string :booking_code, limit: 6
      t.references :user, null: false, foreign_key: true
      t.timestamp :booking_date
      t.integer :status
      t.references :status_changed_by, foreign_key: { to_table: :users }
      t.string :decline_reason, limit: 255

      t.timestamps
    end
  end
end
