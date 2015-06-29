class AddLastReadSystemMessageAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_read_system_message_at, :datetime
  end
end
