class AddFollowsCountToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :follows_count, :integer, default: 0
  end
end
