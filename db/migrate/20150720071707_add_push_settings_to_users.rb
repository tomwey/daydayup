class AddPushSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :push_settings, :string, default: '1,1,1,1,1,1,1,1'
  end
end
