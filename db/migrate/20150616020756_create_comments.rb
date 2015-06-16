class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :note_id
      t.string :body

      t.timestamps
    end
    
    add_index :comments, :user_id
    add_index :comments, :note_id
  end
end
