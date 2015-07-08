class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :note, counter_cache: true
  
  has_many :replies, dependent: :destroy
  
  after_create do
    Message.create!(actor_id: user.id, user_id: note.goal.user, body: "#{note.goal.id}-#{self.id}")
  end
  
end
