# coding: utf-8

module API
  class MessagesAPI < Grape::API
    
    resource :messages do      
      # 获取未读消息
      desc "获取未读消息条数"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :unread_count do
        user = authenticate!
        
        # 检测未读系统消息
        if user.last_read_system_message_at.blank?
          sys_msg_total = Message.where(message_type: 1).count
        else
          sys_msg_total = Message.where('created_at > ? and message_type = 1', user.last_read_system_message_at).count
        end
        
        total = Message.unread.where('message_type != 1 and user_id = ?', user.id).count
        
        # 检测聊天记录
        # if user.last_read_talk_at.blank?
        #   talk_total = Talk.where('receiver_id = ?', user.id).count
        # else
        #   talk_total = Talk.where('created_at > ? and receiver_id = ?', user.last_read_talk_at, user.id).count
        # end
        talk_total = Talk.where('read = ? and receiver_id = ?', false, user.id).count
        
        { code: 0, message: "ok", data: { total: ( total + sys_msg_total + talk_total ) } }
        
      end # end /unread
      
      # 获取最新一条消息列表
      desc "获取最新一条消息列表"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :list do
        user = authenticate!
        
        item = []
        
        (1..4).each do |type|
          if type == 1
            message = Message.where(message_type: type).order('id DESC').first
            if user.last_read_system_message_at.blank?
              count = Message.where(message_type: 1).count
            else
              count = Message.where('created_at > ? and message_type = ?', user.last_read_system_message_at, 1).count
            end
          else
            message = Message.where(user_id: user.id, message_type: type).order('id DESC').first
            count   = Message.unread.where(user_id: user.id, message_type: type).count
          end
          
          if message
            item << { type: type, unread_messages_count: count, latest_message: message }
          end
          
        end
        
        # 获取聊天信息
        sender_ids = Talk.select('sender_id').group(:sender_id).map(&:sender_id)
        sender_ids.each do |id|
          talk = Talk.where('(receiver_id = :id1 and sender_id = :id2) or (sender_id = :id1 and receiver_id = :id2)', id1: user.id, id2: id).order('id DESC').first
          if user.id.to_i == id.to_i
            puts user.id.to_s + '--' + id.to_s
            count = 0
          else
            puts id.to_s
            count = Talk.where('sender_id = ? and read = ?', id, false).count
          end
          
          puts 'count: ' + count.to_s
          
          if talk
            item << { type: 5, unread_messages_count: count, latest_message: talk }
          end
          
        end
        
        { code: 0, message: "ok", data: item }
      end # end list
      
      # 按类别获取消息
      desc "按类别获取消息"
      params do
        requires :token, type: String, desc: "Token"
        requires :message_type, type: Integer, desc: "消息类别"
      end
      get :read do
        user = authenticate!
        
        if params[:message_type].to_i == 1
          # 系统消息
          user.update({ last_read_system_message_at: Time.now })
          @messages = Message.where(message_type: params[:message_type]).order('id ASC')
        else
          Message.where(message_type: params[:message_type], user_id: user.id).unread.update_all(read: true)
          @messages = Message.where(message_type: params[:message_type], user_id: user.id).order('id ASC')
        end
        
        { code: 0, message: "ok", data: @messages }
      end # end read
      
    end # end resource
    
    resource :talks do
      # 发送消息
      desc "发送聊天信息"
      params do
        requires :token, type: String, desc: "Token"
        requires :content, type: String, desc: "聊天内容"
        requires :receiver_id, type: Integer, desc: "接收消息者id"
      end
      post :send do
        sender = authenticate!
        
        m = Talk.create!(sender_id: sender.id, receiver_id: params[:receiver_id], content: params[:content])
        
        { code: 0, message: "ok", data: m }
      end # end send
      
      # 获取某个用户聊天记录
      desc "获取某个用户发出的聊天记录"
      params do
        requires :token, type: String, desc: "Token"
        requires :sender_id, type: Integer, desc: "发送消息者id"
      end
      get :read do
        user = authenticate!
        
        @talks = Talk.where('(sender_id = :user_id_1 and receiver_id = :user_id_2) or (sender_id = :user_id_2 and receiver_id = :user_id_1)', user_id_1: params[:sender_id], user_id_2: user.id)
        .order('id ASC')
        
        # 标记为已读
        Talk.where(receiver_id: user.id).update_all(read: true)
        
        { code: 0, message: "ok", data: @talks }
      end
    end # end talks resource 
    
    resource :feedbacks do
      desc "意见反馈"
      params do
        requires :body, type: String, desc: "反馈内容"
        requires :model, type: String, desc: "设备信息"
        requires :os, type: String, desc: "设备操作系统版本"
        requires :lang, type: String, desc: "设备语言"
        requires :version, type: String, desc: "app当前版本"
        requires :uid, type: String, desc: "用户设备id"
      end
      post :send do
        Feedback.create!(body: params[:body],
                         model: params[:model],
                         os: params[:os],
                         lang: params[:lang],
                         version: params[:version],
                         uid: params[:uid])
        { code: 0, message: "ok" }
      end # end send
    end # end feedbacks resource
    
  end
end