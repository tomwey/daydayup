class AddFollowersCountAndFollowingCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :followers_count, :integer, default: 0
    add_column :users, :following_count, :integer, default: 0
    add_index :users, :followers_count
    add_index :users, :following_count
  end
end
