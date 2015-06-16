class AddImageToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :image, :string
  end
end
