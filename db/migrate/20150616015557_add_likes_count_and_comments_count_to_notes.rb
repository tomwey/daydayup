class AddLikesCountAndCommentsCountToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :likes_count, :integer, default: 0
    add_column :notes, :comments_count, :integer, default: 0
  end
end
