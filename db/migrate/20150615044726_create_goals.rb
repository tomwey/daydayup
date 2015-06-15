class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :title, :null => false
      t.text :body
      t.datetime :expired_at
      t.point :location, geographic: true
      t.integer :category_id
      t.integer :user_id
      t.boolean :is_supervise, default: true

      t.timestamps
    end
    
    add_index :goals, :user_id
    add_index :goals, :category_id
    add_index :goals, :location, using: :gist
  end
end
