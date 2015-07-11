class RemoveIndexFromUsers < ActiveRecord::Migration
  def change
    remove_index :users, :nickname
  end
end
