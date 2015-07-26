# coding: utf-8

module API
  class GoalsAPI < Grape::API
    
    resource :goals do
      
      # 创建目标
      desc "创建目标"
      params do
        requires :token, type: String, desc: "认证Token"
        requires :title, type: String, desc: "目标标题"
        requires :expired_at, type: String, desc: "到期时间"
        requires :is_supervise, type: Integer, desc: "整数，0或1，0表示false, 1表示true"
        optional :body, type: String, desc: "具体目标计划"
        requires :type_id, type: Integer, desc: "类别id"
        requires :latitude, type: String, desc: "纬度，数字字符串，必须"
        requires :longitude, type: String, desc: "经度，数字字符串，必须"
      end
      post :create do
        user = authenticate!
        
        type = Category.find_by(id: params[:type_id])
        if type.blank?
          return { code: 4001, message: "所属类别不存在" }
        end
        
        is_supervise = params[:is_supervise].to_i == 0 ? false : true
        
        g = Goal.new(
                     title: params[:title], 
                     expired_at: params[:expired_at], 
                     is_supervise: is_supervise,
                     body: params[:body],
                     category_id: type.id)
        
        g.user_id = user.id
        
        g.location = 'POINT(' + "#{params[:longitude]}" + ' ' + "#{params[:latitude]}" + ')'
      
        if g.save
          { code: 0, message: "ok", data: g }
        else
          { code: 4002, message: g.errors.full_messages.join(',') }
        end
      end # end create
      
      # 获取附近的目标
      desc "获取附近的目标"
      params do
        requires :latitude, type: String, desc: "纬度，数字字符串，必须"
        requires :longitude, type: String, desc: "经度，数字字符串，必须"
        optional :gender, type: Integer, desc: "性别，如果gender不传则表示加载全部"
        optional :type_id, type: Integer, desc: "类别id"
        optional :token, type: String, desc: "认证Token"
      end
      get :nearby do
        @goals = Goal.select("goals.*, user_id, st_distance(location, 'point(#{params[:longitude]} #{params[:latitude]})') as distance").order("distance ASC, id DESC").distinct('user_id')
        
        if params[:gender]
          @goals = @goals.joins(:user).where('users.gender = ?', params[:gender])
        end
        
        if params[:type_id]
          @type = Category.find_by(id: params[:type_id])
          if @type and @type.name != '全部'
            @goals = @goals.joins(:category).where('categories.id = ?', params[:type_id])
          end
        end
        
        @goals = @goals.paginate(page: params[:page], per_page: page_size).all
        
        user = User.find_by(private_token: params[:token])
        if user.present?
          @goals.each do |g|
            g.user.is_followed = user.following?(g.user)
          end
        end
        
        { code: 0, message: 'ok', data: @goals }
      end # end nearby
      
      # 获取目标列表
      desc "获取目标列表"
      params do
        requires :type_id, type: Integer, desc: "类别ID"
        optional :token, type: String, desc: "认证Token"
      end
      get '/:filter' do
        @type = Category.find_by(id: params[:type_id])
        if @type.blank?
          return { code: 4001, message: "没有找到该类别" }
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
      
      # 获取目标记录列表
      desc "获取目标记录列表"
      params do
        requires :type_id, type: Integer, desc: "类别ID"
        optional :token, type: String, desc: "认证Token"
      end
      get '/:filter/notes' do
        @type = Category.find_by(id: params[:type_id])
        if @type.blank?
          return { code: 4001, message: "没有找到该类别" }
        end
        
        @notes = Note.joins(:goal).where('goals.visible = ? and goals.is_abandon = ?', true, false).send(params[:filter].to_sym)
        if @type.name != '全部'
          @notes = @notes.where('goals.category_id = ?', @type.id)
        end
        
        @notes = @notes.paginate(page: params[:page], per_page: page_size).all
        
        user = User.find_by(private_token: params[:token])
        if user.present?
          @notes.each do |note| 
            note.blike = user.liked?(note)
          end
        end
        
        { code: 0, message: 'ok', data: @notes }
        
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
            is_supervised: @goal.is_supervised?,
            need_supervise: @goal.is_supervise,
            supervisor: @goal.supervisor,
            is_cheered: @goal.is_cheered || false,
            is_followed: @goal.is_followed || false,
            is_abandon: @goal.is_abandon,
            notes: @goal.notes.includes(:photos).order('id desc') || [],
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
        
        if @note.blank?
          return { code: 4001, message: "该记录不存在" }
        end
        
        user = User.find_by(private_token: params[:token])
        if user.present?
          @note.blike = user.liked?(@note)
          owner = @note.goal.user
          owner.is_followed = user.following?(owner)
        else
          @note.blike = false
        end
        
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
          return { code: 2002, message: "您已经关注了该目标，不能多次关注" }
        end
        
        if user.follow_goal(@goal)
          { code: 0, message: "ok" }
        else
          { code: 2003, message: "关注目标失败" }
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
          { code: 2004, message: "取消关注目标失败" }
        end
        
      end # end 取消关注目标
      
      # 督促目标
      # desc "督促目标"
      # params do
      #   requires :token, type: String, desc: "认证Token"
      # end
      # post '/:goal_id/supervise' do
      #   user = authenticate!
      #
      #   @goal = Goal.find(params[:goal_id])
      #
      #   # if @goal.update_attribute(:supervisor_id, user.id)
      #   #   user.change_supervises_count(1)
      #   #   { code: 0, message: "ok" }
      #   # else
      #   #   { code: 2003, message: "督促失败" }
      #   # end
      # end # end supervise
      
      # 给目标加油
      desc "给目标加油"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/cheer' do
        user = authenticate!
        
        goal = Goal.find_by(id: params[:goal_id])
        if goal.blank?
          return { code: 4001, message: "该目标不存在" }
        end
        
        if user.cheer(goal)
          Message.create!(actor_id: user.id, user_id: goal.user.id, body: goal.id, message_type: 3)
          { code: 0, message: "ok" }
        else
          { code: 2005, message: "加油失败" }
        end
        
      end # end cheer
      
      # 取消给目标加油
      desc "取消给目标加油"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/uncheer' do
        user = authenticate!
        
        goal = Goal.find_by(id: params[:goal_id])
        if goal.blank?
          return { code: 4001, message: "该目标不存在" }
        end
        
        if user.uncheer(goal)
          { code: 0, message: "ok" }
        else
          { code: 2006, message: "取消加油失败" }
        end
        
      end # end uncheer
      
      # 放弃目标
      desc "放弃目标"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/abandon' do
        user = authenticate!
        
        @goal = user.goals.find(params[:goal_id])
        
        if @goal.update_attribute(:is_abandon, true)
          { code: 0, message: "ok" }
        else
          { code: 2007, message: "放弃目标失败" }
        end
      end # end abandon
      
      # 删除目标
      desc "删除目标"
      params do
        requires :token, type: String, desc: "认证Token"
      end
      post '/:goal_id/delete' do
        user = authenticate!
        
        @goal = user.goals.find(params[:goal_id])
        
        if @goal.update_attribute(:visible, false)
          { code: 0, message: "ok" }
        else
          { code: 2008, message: "删除目标失败" }
        end
      end # end delete
      
    end # end resource 
    
  end
end
