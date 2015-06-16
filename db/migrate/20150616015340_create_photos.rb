class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :image
      t.integer :note_id

      t.timestamps
    end
    add_index :photos, :note_id
  end
end
