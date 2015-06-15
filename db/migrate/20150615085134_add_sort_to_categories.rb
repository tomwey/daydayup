class AddSortToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :sort, :integer, default: 20
  end
end
