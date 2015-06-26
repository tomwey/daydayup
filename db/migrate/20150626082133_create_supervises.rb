class CreateSupervises < ActiveRecord::Migration
  def change
    create_table :supervises do |t|
      t.integer :user_id
      t.integer :goal_id
      t.boolean :accepted, default: false

      t.timestamps
    end
    
    add_index :supervises, :user_id
    add_index :supervises, :goal_id
    add_index :supervises, [:user_id, :goal_id], unique: true
  end
end
