class AddGoalIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :goal_id, :integer
    add_index :notes, :goal_id
  end
end
