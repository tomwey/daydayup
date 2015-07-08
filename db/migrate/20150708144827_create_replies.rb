class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :body
      t.integer :user_id
      t.integer :comment_id

      t.timestamps
    end
    add_index :replies, :user_id
    add_index :replies, :comment_id
  end
end
