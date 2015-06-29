class AddReadToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :read, :boolean, default: false
  end
end
