class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :title
      t.text :body
      t.string :image
      t.integer :category_id

      t.timestamps
    end
    
    add_index :banners, :category_id
  end
end
