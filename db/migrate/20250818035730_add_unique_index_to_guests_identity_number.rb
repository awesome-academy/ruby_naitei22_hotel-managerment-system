class AddUniqueIndexToGuestsIdentityNumber < ActiveRecord::Migration[7.0]
  def change
    add_index :guests, :identity_number, unique: true
  end
end
