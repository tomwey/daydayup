class Talk < ActiveRecord::Base
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
  
  validates :sender_id, :receiver_id, :content, presence: true
  
  after_create do
    to = []
    to << self.receiver.mobile if self.receiver
    PushService.push("有人给您打招呼了", 
                     to, { nickname: self.sender.nickname || '匿名', avatar: self.sender.avatar_url, msg: self.content || '' })
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      msg: self.content,
      sender: self.sender || {},
      receiver: self.receiver || {},
      send_time: self.created_at.strftime('%Y-%m-%d %H:%M:%S')
    }
  end
  
end
