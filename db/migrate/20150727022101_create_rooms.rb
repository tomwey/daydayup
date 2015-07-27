class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :sponsor_id
      t.integer :audience_id
      t.integer :talks_count, default: 0

      t.timestamps
    end
    add_index :rooms, :sponsor_id
    add_index :rooms, :audience_id
  end
end
