class AddColumnsToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :model, :string
    add_column :feedbacks, :os, :string
    add_column :feedbacks, :version, :string
    add_column :feedbacks, :lang, :string
    add_column :feedbacks, :uid, :string
  end
end
