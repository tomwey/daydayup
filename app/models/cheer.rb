class Cheer < ActiveRecord::Base
  belongs_to :user
  belongs_to :goal, counter_cache: true
end