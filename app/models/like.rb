class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :note, counter_cache: true
end
