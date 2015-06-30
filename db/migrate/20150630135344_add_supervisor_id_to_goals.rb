class AddSupervisorIdToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :supervisor_id, :integer
    add_index :goals, :supervisor_id
  end
end
