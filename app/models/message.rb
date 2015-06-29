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
      content: self.body || '',
      type: self.message_type,
      send_time: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
      actor: self.actor || {},
    }
  end
  
end

# body 如果是系统消息，则为消息的内容；如果是评论，字段的内容为目标id加当前评论的id，例如：'2-3'；如果是加油，那么字段内容为目标的id
