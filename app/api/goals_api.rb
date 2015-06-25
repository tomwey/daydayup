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
        
        # render_json(@goal, API::Entities::GoalDetail)
        { code: 0, message: 'ok', data: {
            id: @goal.id,
            title: @goal.title || "",
            body: @goal.body || "",
            expired_at: @goal.expired_at.strftime('%Y-%m-%d %H:%M:%S'),
            follows_count: @goal.follows_count,
            cheers_count: @goal.cheers_count,
            is_supervised: !!@goal.supervisor_id,
            is_cheered: @goal.is_cheered || false,
            is_followed: @goal.is_followed || false,
            notes: @goal.notes.order('id desc') || [],
            type: @goal.category || {},
            owner: @goal.user || {},
        } }
        
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
        
      end # end 获取记录详情
      
      # 关注目标
      desc "关注目标"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/follow' do
        user = authenticate!
        
        @goal = Goal.find(params[:goal_id])
        
        if user == @goal.user
          return { code: 2001, message: "不能关注自己的目标" }
        end
        
        if user.following_goal?(@goal)
          return { code: 2001, message: "您已经关注了该目标，不能多次关注" }
        end
        
        if user.follow_goal(@goal)
          { code: 0, message: "ok" }
        else
          { code: 2001, message: "关注目标失败" }
        end
        
      end # end 关注目标
      
      # 取消关注目标
      desc "取消关注目标"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/unfollow' do
        user = authenticate!
        
        @goal = Goal.find(params[:goal_id])
        
        if user.unfollow_goal(@goal)
          { code: 0, message: "ok" }
        else
          { code: 2002, message: "取消关注目标失败" }
        end
        
      end # end 取消关注目标
      
      # 督促目标
      desc "督促目标"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/supervise' do
        user = authenticate!
        
        @goal = Goal.find(params[:goal_id])
        
        if @goal.update_attribute(:supervisor_id, user.id)
          { code: 0, message: "ok" }
        else
          { code: 2003, message: "督促失败" }
        end
      end # end supervise
      
      # 给目标加油
      desc "给目标加油"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/cheer' do
        user = authenticate!
        
        if user.cheer(goal)
          { code: 0, message: "ok" }
        else
          { code: 2004, message: "加油失败" }
        end
        
      end # end cheer
      
      # 取消给目标加油
      desc "取消给目标加油"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/uncheer' do
        user = authenticate!
        
        if user.uncheer(goal)
          { code: 0, message: "ok" }
        else
          { code: 2004, message: "取消加油失败" }
        end
        
      end # end uncheer
      
    end # end resource 
    
  end
end
