# coding: utf-8
require 'jpush'
class PushService
    
  def self.publish(message)
    
    actor_name = message.actor.try(:nickname) || ''
    msg = actor_name + message.body
    
    if message.message_type.to_i == 1
      # 系统消息，推送给所有人
      PushService.push(msg)
    else
      # 其他消息推送给指定的人
      to = []
      to << message.user.mobile if message.user
      PushService.push(msg, to, { actor: { nickname: message.actor.nickname, avatar: message.actor.avatar_url } })
    end
    
  end
  
  def self.push(msg, receipts = [], extras_data = {})
    client = JPush::JPushClient.new('0b5929744cf9e0f018267d19', '7692f9b1cd39df15f67eec47');
      
    logger = Logger.new(STDOUT);
    
    if receipts.any?
      tags = receipts.map { |to| "tel#{to}" }
      audience = JPush::Audience.build(tag: tags)
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