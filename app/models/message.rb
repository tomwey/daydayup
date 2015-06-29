class Message < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :actor, class_name: "User", foreign_key: "actor_id"
  
  scope :unread, -> { where(read: false) }
  
  after_create do
    PushService.publish(self)
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      content: self.body || "",
      type: self.message_type,
      send_time: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
      actor: self.actor || {},
    }
  end
  
end
