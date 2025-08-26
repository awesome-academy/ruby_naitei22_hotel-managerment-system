class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def self.up
    change_table :users do |t|
      t.rename :password_digest, :encrypted_password
      t.change :encrypted_password, :string, null: false, default: ""

      t.rename :reset_digest, :reset_password_token
      t.rename :reset_sent_at, :reset_password_sent_at

      t.datetime :remember_created_at

      t.rename :activation_digest, :confirmation_token
      t.rename :activated_at, :confirmed_at
      t.datetime :confirmation_sent_at
      t.remove :remember_digest
    end

    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end

  def self.down
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
    
    change_table :users do |t|
      ## Rollback Database authenticatable
      t.rename :encrypted_password, :password_digest
      t.change :password_digest, :string, null: true

      ## Rollback Recoverable
      t.rename :reset_password_token, :reset_digest
      t.rename :reset_password_sent_at, :reset_sent_at

      ## Rollback Rememberable
      t.remove :remember_created_at
      t.string :remember_digest

      ## Rollback Confirmable
      t.rename :confirmation_token, :activation_digest
      t.rename :confirmed_at, :activated_at
      t.remove :confirmation_sent_at
    end
  end
end
