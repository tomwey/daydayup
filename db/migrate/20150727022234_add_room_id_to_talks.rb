class AddRoomIdToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :room_id, :integer
    add_index :talks, :room_id
  end
end
