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
        
        if user == goal.user
          return { code: 4003, message: "自己不能督促自己的目标" }
        end
        
        Supervise.create!(user_id: user.id, goal_id: goal.id)
        
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
        
        # 只有同意督促后，目标才有督促人，才可以更换督促人
        supervise = Supervise.where(goal_id: @goal.id, accepted: true).first
        if supervise.blank?
          return { code: 4007, message: "要更换的督促不存在" }
        end
        
        # 减少目标督促数
        supervise.user.change_supervises_count(-1) if supervise.user
        
        @goal.update_attribute(:supervisor_id, nil)
        
        supervise.destroy
        
        { code: 0, message: "ok" }
        
      end # end destroy
      
    end # end resource 
    
  end
end
