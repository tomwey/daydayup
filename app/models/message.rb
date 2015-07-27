class Message < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :actor, class_name: "User", foreign_key: "actor_id"
  
  scope :unread, -> { where(read: false) }
  
  validates_presence_of :body
  
  after_create do
    if user.blank? or user.push_opened_for?(self.message_type.to_i)
      PushService.publish(self)
    end
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      type: self.message_type,
      content: self.content,
      comment_body: self.comment_body,
      sender: self.actor || {},
      receiver: self.user || {},
      send_time: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    }
  end
  
  def content
    case self.message_type.to_i
    when 1 then self.body || ''
    when 2 then self.goal_title
    when 3 then self.goal_title
    when 4 then '关注了我'
    else ''
    end
  end
  
  def message_body
    case self.message_type.to_i
    when 1 then self.body || ''
    when 2 then actor_name + '：评论了我的目标【' + self.goal_title + '】'
    when 3 then actor_name + '：加油了我的目标【' + self.goal_title + '】'
    when 4 then actor_name + '：关注了我'
    else ''
    end
  end
  
  def actor_name
    self.actor.try(:nickname) || self.actor.try(:mobile) || '系统'
  end
  
  def comment_body
    if self.message_type.to_i == 2
      self.body.split('-').last
    else
      ""
    end
  end
  
  def goal_title
    goal_id = self.body.split('-').first
    Goal.find_by(id: goal_id).try(:title)
  end
  
end

# body 如果是系统消息，则为消息的内容；如果是评论，字段的内容为目标id加当前评论的id，例如：'2-3'；如果是加油，那么字段内容为目标的id
