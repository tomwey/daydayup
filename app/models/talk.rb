class Talk < ActiveRecord::Base
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
  
  belongs_to :room, counter_cache: true
  
  validates :sender_id, :receiver_id, :content, :room_id, presence: true
  
  after_create do
    if self.receiver.push_opened_for?(5)
      to = []
      to << self.receiver.private_token if self.receiver
      PushService.push("有人给您打招呼了", 
                       to, { type: 5, actor: { id: self.sender.try(:id), nickname: self.sender.try(:nickname) || '匿名', avatar: self.sender.try(:avatar_url), msg: self.content || '' } })
    end
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      type: 5,
      content: self.content,
      sender: self.sender || {},
      receiver: self.receiver || {},
      send_time: self.created_at.strftime('%Y-%m-%d %H:%M:%S')
      # is_i_sent: 
    }
  end
  
end
