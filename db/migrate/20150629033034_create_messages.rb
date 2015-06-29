class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body, :null => false
      t.integer :user_id
      t.integer :actor_id
      t.integer :message_type, default: 1 # 1 系统消息 2 评论消息 3 加油消息 4 关注消息
      t.boolean :read, default: false

      t.timestamps
    end
    add_index :messages, :user_id
    add_index :messages, :actor_id
    add_index :messages, :message_type
    add_index :messages, :read
  end
end
