class RemoveSupervisorIdFromGoals < ActiveRecord::Migration
  def change
    remove_index :goals, :supervisor_id
    remove_column :goals, :supervisor_id
  end
end
