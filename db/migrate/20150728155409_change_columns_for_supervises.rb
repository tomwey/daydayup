class ChangeColumnsForSupervises < ActiveRecord::Migration
  def change
    remove_column :supervises, :accepted
    add_column :supervises, :state, :string
  end
end
