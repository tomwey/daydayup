class AddSupervisesCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :supervises_count, :integer, default: 0
    add_index :users, :supervises_count
  end
end
