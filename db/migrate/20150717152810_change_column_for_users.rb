class ChangeColumnForUsers < ActiveRecord::Migration
  def change
    change_column :users, :mobile, :string, :null => true
  end
end
