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
        
        { code: 0, message: "ok", data: { total: total + sys_msg_total } }
        
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
    
  end
end