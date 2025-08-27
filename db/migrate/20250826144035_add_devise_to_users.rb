# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def self.up
    # Xóa các cột cũ nếu tồn tại
    remove_column :users, :email, :string if column_exists?(:users, :email)
    remove_column :users, :password_digest, :string if column_exists?(:users, :password_digest)
    remove_column :users, :remember_digest, :string if column_exists?(:users, :remember_digest)
    remove_column :users, :activation_digest, :string if column_exists?(:users, :activation_digest)
    remove_column :users, :activated, :boolean if column_exists?(:users, :activated)
    remove_column :users, :activated_at, :datetime if column_exists?(:users, :activated_at)
    remove_column :users, :reset_digest, :string if column_exists?(:users, :reset_digest)
    remove_column :users, :reset_sent_at, :datetime if column_exists?(:users, :reset_sent_at)

    change_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
      t.string :remember_token

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end

    add_index :users, :email, unique: true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
