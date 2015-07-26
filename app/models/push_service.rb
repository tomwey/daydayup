# coding: utf-8
require 'jpush'
class PushService
    
  def self.publish(message)
    if message.message_type.to_i == 1
      # 系统消息，推送给所有人
      PushService.push(message.body)
    else
      # 其他消息推送给指定的人
      actor_name = message.actor.try(:nickname) || ''
      
      msg = if message.message_type.to_i == 2
        actor_name + '评论了我的目标'
      elsif message.message_type.to_i == 3
        actor_name + '给我的目标加油了'
      elsif message.message_type.to_i == 4
        actor_name + "关注了我"
      else
        ''
      end
      
      to = []
      to << message.user.private_token if message.user
      PushService.push(msg, to, { actor: { nickname: message.actor.nickname, avatar: message.actor.avatar_url } })
    end
    
  end
  
  def self.push(msg, receipts = [], extras_data = {})
    client = JPush::JPushClient.new('112e6f664d3de8d9a6864198', '2a7fe23061a46e24c12451f2');
      
    logger = Logger.new(STDOUT);
    
    if receipts.any?
      # tags = receipts.map { |to| "tel#{to}" }
      audience = JPush::Audience.build(tag: receipts)
    else
      audience = JPush::Audience.all
    end
    
    payload = JPush::PushPayload.build(
      platform: JPush::Platform.all,
      audience: audience,
      notification: JPush::Notification.build(
        ios: JPush::IOSNotification.build(
          alert: msg,
          sound: "default",
          extras: extras_data
        ),
        android: JPush::AndroidNotification.build(
          alert: msg,
          extras: extras_data
        )
      )
    )
    
    begin
      result = client.sendPush(payload);
      logger.debug("Got result " + result.toJSON)
    rescue JPush::ApiConnectionException
      logger.debug("没有找到用户")
    end
    
  end
  
end