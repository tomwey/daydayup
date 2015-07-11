class AddProviderIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider_id, :string
    add_index :users, :provider_id
  end
end
