class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.integer :rating
      t.text :comment
      t.references :approved_by, foreign_key: { to_table: :users }
      t.integer :review_status

      t.timestamps
    end
  end
end
