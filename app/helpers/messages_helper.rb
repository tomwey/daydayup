module MessagesHelper
  def render_message_type(message)
    return "" if message.blank?
    
    case message.message_type.to_i
    when 1 then '系统消息'
    when 2 then '评论消息'
    when 3 then '加油消息'
    when 4 then '关注消息'
    else ''
    end
    
  end
  
end