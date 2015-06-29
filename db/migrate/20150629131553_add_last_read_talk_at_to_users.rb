class AddLastReadTalkAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_read_talk_at, :datetime
  end
end
