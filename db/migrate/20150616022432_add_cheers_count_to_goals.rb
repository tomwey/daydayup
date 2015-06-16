class AddCheersCountToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :cheers_count, :integer, default: 0
  end
end
