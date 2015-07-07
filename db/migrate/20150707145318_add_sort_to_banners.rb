class AddSortToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :sort, :integer, default: 20
  end
end
