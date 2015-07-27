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
        
        # sender_id, receiver_id, content
        # 获取聊天信息
        rooms = Room.where('sponsor_id = :id or audience_id = :id', id: user.id)
        rooms.each do |room|
          latest_talk = room.talks.order('id DESC').first
          if latest_talk
            if user.id.to_i == room.sponsor_id.to_i
              audience = room.audience
            else
              audience = room.sponsor
            end
            count = room.talks.where('receiver_id = ? and read = ?', user.id, false).count
            item << { type: 5, unread_messages_count: count, latest_message: { id: room.id, audience: audience, content: latest_talk.content } }
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
        
        if sender.id.to_i == params[:receiver_id].to_i
          return { code: -4, message: "你不能跟自己聊天" }
        end
        
        room = Room.where('(sponsor_id = :id1 and audience_id = :id2) or (sponsor_id = :id2 and audience_id = :id1)', id1: sender.id, id2: params[:receiver_id]).first
        if room.blank?
          room = Room.create(sponsor_id: sender.id, audience_id: params[:receiver_id])
          if room.blank?
            return { code: -5, message: "开启会话失败" }
          end
        end
        
        m = Talk.create!(sender_id: sender.id, receiver_id: params[:receiver_id], content: params[:content], room_id: room.id)
        
        { code: 0, message: "ok", data: m }
      end # end send
      
      # 获取某个用户聊天记录
      desc "获取某个用户发出的聊天记录"
      params do
        requires :token, type: String, desc: "Token"
        requires :room_id, type: Integer, desc: "发送消息者id"
      end
      get :read do
        user = authenticate!
        
        room = Room.find_by(id: params[:room_id])
        if room.blank?
          return { code: 4001, message: "未找到该聊天会话" }
        end
        
        @talks = room.talks.order('id ASC')
        if params[:page]
          @talks = @talks.paginate page: params[:page], per_page: page_size
        end
        
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