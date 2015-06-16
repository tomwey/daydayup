class CreateCheers < ActiveRecord::Migration
  def change
    create_table :cheers do |t|
      t.integer :user_id
      t.integer :goal_id

      t.timestamps
    end
    add_index :cheers, :user_id
    add_index :cheers, :goal_id
    add_index :cheers, [:user_id, :goal_id], unique: true
  end
end
