class AddColumnsForUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :integer, default: 1 # 1 表示男，2 表示女，3 表示其他
    add_column :users, :age, :integer
    add_column :users, :level, :integer
    add_column :users, :constellation, :string # 星座
  end
end
