class CreateTalks < ActiveRecord::Migration
  def change
    create_table :talks do |t|
      t.text :content, :null => false
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
    
    add_index :talks, :sender_id
    add_index :talks, :receiver_id
    
  end
end
