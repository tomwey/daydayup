class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.integer :goal_id

      t.timestamps
    end
    
    add_index :follows, :user_id
    add_index :follows, :goal_id
    add_index :follows, [:user_id, :goal_id], unique: true
  end
end
