class AddIsAbandonAndVisibleToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :is_abandon, :boolean, default: false
    add_column :goals, :visible, :boolean, default: true
  end
end
