class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :note, counter_cache: true
  
  # has_many :replies, dependent: :destroy
  
  after_create do
    if note.goal.user.id != self.user.id
      Message.create!(actor_id: user.id, message_type: 2, user_id: note.goal.user.id, body: "#{note.goal.id}-#{self.id}")
    end
  end
  
  def at_user
    if self.at_who.blank?
      {}
    else
      u = User.find_by(id: at_who)
      u.as_json
    end
  end
  
end
