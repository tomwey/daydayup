# coding: utf-8

module API
  class SupervisesAPI < Grape::API
    
    resource :supervises do
      # 督促目标
      desc "督促目标"
      params do
        requires :token, type: String, desc: "Token"
        requires :goal_id, type: Integer, desc: "目标id"
      end
      post :create do
        user = authenticate!
        
        goal = Goal.find(params[:goal_id])
        
        if goal.is_abandon
          return { code: 4013, message: "目标已经放弃，不能督促" }
        end
        
        if goal.completed?
          return { code: 4013, message: "目标已经完成，不能督促" }
        end
        
        if goal.supervisor_id.present?
          return { code: 4013, message: "该目标已经有督促人了" }
        end
        
        if user == goal.user
          return { code: 4003, message: "自己不能督促自己的目标" }
        end
        
        supervise = Supervise.find_by(user_id: user.id, goal_id: goal.id)
        if supervise.present?
          return { code: 4010, message: "您已经督促过该目标，不能督促了" }
        end
        
        Supervise.create!(user_id: user.id, goal_id: goal.id)
        
        # 发送消息
        if goal.user.push_opened_for?(6)
          msg = user.nickname || user.mobile + '请求督促您的目标' + goal.title
          to = []
          to << goal.user.private_token
          PushService.push(msg, to)
        end
        
        { code: 0, message: "ok" }
        
      end # end create
      
      # 接受目标督促
      desc "接受目标督促"
      params do
        requires :token, type: String, desc: "Token"
        requires :goal_id, type: Integer, desc: "目标id"
      end
      post '/:id/accept' do
        user = authenticate!
        
        @goal = user.goals.find(params[:goal_id])
        
        supervise = Supervise.where(id: params[:id], goal_id: @goal.id, accepted: false).first
        
        if supervise.blank?
          return { code: 4004, message: "要接受的督促不存在" }
        end
        
        if supervise.update_attribute(:accepted, true)
          supervise.user.change_supervises_count(1)
          @goal.update_attribute(:supervisor_id, supervise.user.id)
          
          # 发送消息
          if supervise.user.push_opened_for?(6)
            msg = '我申请督促目标' + @goal.title + '被通过'
            to = []
            to << supervise.user.private_token
            PushService.push(msg, to)
          end
          
          { code: 0, message: "ok" }
        else
          { code: 4005, message: "接受督促失败" }
        end
        
      end # end accept
      
      # 拒绝目标督促
      desc "拒绝目标督促"
      params do
        requires :token, type: String, desc: "Token"
        requires :goal_id, type: Integer, desc: "目标id"
      end
      post '/:id/refuse' do
        user = authenticate!
        
        @goal = user.goals.find(params[:goal_id])
        
        supervise = Supervise.where(id: params[:id], goal_id: @goal.id, accepted: false).first
        
        if supervise.blank?
          return { code: 4006, message: "要拒绝的督促不存在" }
        end
        
        # 发送消息
        if supervise.user.push_opened_for?(6)
          msg = '我申请督促目标' + @goal.title + '被拒绝'
          to = []
          to << supervise.user.private_token
          PushService.push(msg, to)
        end
        
        supervise.destroy
        
        { code: 0, message: "ok" }
        
      end # end refuse
      
      # 更换目标督促人
      desc "更换目标督促人"
      params do
        requires :token, type: String, desc: "Token"
        requires :goal_id, type: Integer, desc: "目标id"
      end
      post :destroy do
        user = authenticate!
        
        @goal = user.goals.find(params[:goal_id])
        
        if @goal.supervisor_id.blank?
          return { code: 4009, message: "该目标没有督促人" }
        end
        
        # 只有同意督促后，目标才有督促人，才可以更换督促人
        supervise = Supervise.where(goal_id: @goal.id, accepted: true, user_id: @goal.supervisor_id).first
        if supervise.blank?
          return { code: 4007, message: "要更换的督促不存在" }
        end
        
        # 减少目标督促数
        supervise.user.change_supervises_count(-1) if supervise.user
        
        if @goal.update_attribute(:supervisor_id, nil)
          { code: 0, message: "ok" }
        else
          { code: 4008, message: "更换督促人失败" }
        end
        
      end # end destroy
      
      # 删除非督促
      desc '删除非督促'
      params do
        requires :token, type: String, desc: "Token"
      end
      post '/:supervise_id/destroy' do
        user = authenticate!
        
        s = Supervise.find_by(user_id: user.id, id: params[:supervise_id])
        if s.blank?
          return { code: 4001, message: "该督促不存在" }
        end
        
        if s.destroy
          { code: 0, message: "ok" }
        else
          { code: 4020, message: "删除督促失败" }
        end
        
      end # end destroy
      
    end # end resource 
    
  end
end
