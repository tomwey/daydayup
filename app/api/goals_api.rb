# coding: utf-8

module API
  class GoalsAPI < Grape::API
    
    resource :goals do
      
      # 获取目标列表
      desc "获取目标列表"
      params do
        requires :type_id, type: Integer, desc: "类别ID"
        optional :token, type: String, desc: "认证Token"
      end
      get '/:filter' do
        @type = Category.find_by(id: params[:type_id])
        if @type.blank?
          return { code: -100, message: "没有找到该类别" }
        end
        
        @goals = Goal.send(params[:filter].to_sym)
        if @type.name != '全部'
          @goals = @goals.where(category_id: @type.id)
        end
        
        @goals = @goals.paginate(page: params[:page], per_page: page_size).all
        
        user = User.find_by(private_token: params[:token])
        if user.present?
          @goals.each do |g|
            g.user.is_followed = user.following?(g.user)
          end
        end

        { code: 0, message: 'ok', data: @goals }
      end # end /:filter
      
      # 获取目标详情
      desc "获取目标详情"
      params do 
        optional :token, type: String, desc: "认证Token"
      end
      get '/show/:id' do
        @goal = Goal.find_by(id: params[:id])
        if @goal.blank?
          return { code: 0, message: 'ok', data: {} }
        end
        
        user = User.find_by(private_token: params[:token])
        if user
          @goal.is_cheered = Cheer.where('user_id = ? and goal_id = ?', user.id, @goal.id).count > 0
          @goal.is_followed = Follow.where('user_id = ? and goal_id = ?', user.id, @goal.id).count > 0
        else
          @goal.is_cheered = false
          @goal.is_followed = false
        end
        
        render_json(@goal, API::Entities::GoalDetail)
        
      end # end show/:id
      
      # 获取记录详情
      desc "获取记录详情"
      params do
        optional :token, type: String, desc: "认证Token"
      end
      get '/:goal_id/notes/:note_id' do
        @goal = Goal.find(params[:goal_id])
        @note = @goal.notes.find_by(id: params[:note_id])
        
        render_json(@note, API::Entities::NoteDetail)
        
      end
      
    end # end resource 
    
  end
end
