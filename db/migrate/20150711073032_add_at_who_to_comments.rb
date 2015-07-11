class AddAtWhoToComments < ActiveRecord::Migration
  def change
    add_column :comments, :at_who, :integer
    add_index :comments, :at_who
  end
end
