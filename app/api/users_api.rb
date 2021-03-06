# coding: utf-8

require "rest_client"

module API
  class UsersAPI < Grape::API
    
    resource :account do
      
      # 用户登录
      params do
        requires :mobile, type: String, desc: "用户手机号，必须"
        requires :code, type: String, desc: "验证码，必须"
      end
      
      post :login do
        # 手机号验证
        unless check_mobile(params[:mobile])
          return { code: 1001, message: "不正确的手机号" }
        end
        
        # 检查验证码是否有效
        # ac = AuthCode.where('mobile = ? and code = ? and verified = ?', params[:mobile], params[:code], true).first
        # if ac.blank?
        #   return { code: 1004, message: "验证码无效" }
        # end
        
        # 客户端验证code的正确性
        # if not params[:mobile].to_s == '13678158221' # 苹果测试账号
        #   result = check_code(params[:mobile], params[:code])
        #   if result['code'].to_i == -1
        #     return result
        #   end
        # else
        #   if not params[:code].to_s == '300195'
        #     return { code: -1, message: "不正确的验证码" }
        #   end
        # end
        
        # 快捷登录
        user = User.find_by(mobile: params[:mobile])
        if user.present?
          # ac.update_attribute('verified', false)
          return { code: 0, message: "ok", data: user }
        end
        
        user = User.new(mobile: params[:mobile])
        if user.save
          # ac.update_attribute('verified', false)
          { code: 0, message: "ok", data: user }
        else
          { code: 1005, message: "用户登录失败" }
        end
        
      end # end account login
      
    end # end account resource
    
    resource :users do
      # 排行榜
      # goal_geek, supervise_geek, popular_geek
      desc "达人排名"
      params do
        optional :gender, type: Integer, desc: "性别，1为男，2为女"
        optional :type_id, type: Integer, desc: "类别id"
      end
      get '/:filter' do
        if params[:type_id]
          @type = Category.find_by(id: params[:type_id])
          if @type.blank?
            return { code: 4001, message: "该类别不存在" }
          end
        end
        
        @users = User.send(params[:filter].to_sym)
        
        @type = Category.find_by(id: params[:type_id])
        if @type and @type.name != '全部'
          user_ids = Goal.select('user_id').where(category_id: @type.id).group(:user_id).map(&:user_id)
          @users = @users.where(id: user_ids)
          # @users = @users.joins(:goals).where('goals.category_id = ?', @type.id)
        end
        
        if params[:gender]
          @users = @users.where(gender: params[:gender])
        end
        
        @users = @users.order('id DESC').paginate(page: params[:page], per_page: page_size)
        
        { code: 0, message: "ok", data: @users }
      end
      
      # 获取用户详情
      desc "获取用户详情"
      params do
        optional :token, type: String, desc: "Token"
      end
      get '/show/:id' do
        @user = User.find_by(id: params[:id])
        
        if @user.blank?
          return { code: 4001, message: "未找到该用户" }
        end
        
        if params[:token]
          user = User.find_by(private_token: params[:token])
          @user.is_followed = user.following?(@user)
        else
          @user.is_followed = false
        end
        
        render_json(@user, API::Entities::UserDetail)
        
      end
      
    end # end users resource
    
    resource :user do
      
      # 第三方登录绑定用户数据
      desc "第三方登录绑定用户数据"
      params do
        requires :provider_id, type: String, desc: "第三方用户标示id"
        optional :mobile, type: String, desc: "手机号"
        optional :avatar, desc: "二进制图片数据"
        optional :avatar_url, type: String, desc: "头像图片地址"
        optional :nickname, type: String, desc: "昵称"
        optional :gender, type: Integer, desc: "性别，1表示男，2表示女"
        optional :age, type: Integer, desc: "年龄"
        optional :constellation, type: String, desc: "星座"
        optional :signature, type: String, desc: "签名"
      end
      post :bind do
        
        user = User.find_by(provider_id: params[:provider_id])
        if user.present?
          return { code: 0, message: "ok", data: user }
        end
        
        # 新建用户
        user = User.new
        
        user.provider_id = params[:provider_id]
        
        if params[:mobile]
          if not check_mobile(params[:mobile])
            return { code: 1001, message: "不正确的手机号" }
          end
          
          user.mobile = params[:mobile]
        end
        
        if params[:avatar_url]
          user.remote_avatar_url = params[:avatar_url]
        elsif params[:avatar]
          user.avatar = params[:avatar]
        end
        
        # if params[:avatar]
        #   user.avatar = params[:avatar]
        # end
        
        if params[:nickname]
          user.nickname = params[:nickname]
        end
        
        if params[:age]
          user.age = params[:age]
        end
        
        if params[:gender]
          user.gender = params[:gender]
        end
        
        if params[:constellation]
          user.constellation = params[:constellation]
        end
        
        if params[:signature]
          user.signature = params[:signature]
        end
        
        if user.save(validate: false)
          { code: 0, message: "ok", data: user }
        else
          { code: 1006, message: user.errors.full_messages.join(",") }
        end
      end # end bind
      
      # 我的目标
      desc "我的目标"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :goals do
        user = authenticate!
        
        @goals = user.goals.includes(:supervises).no_deleted.order('id desc').paginate page: params[:page], per_page: page_size
        
        render_json(@goals, API::Entities::MyGoalDetail)
      end # end 
      
      # 我督促的目标
      desc "我督促的目标"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :supervised_goals do
        user = authenticate!
        
        @goals = Goal.joins(:supervises).where('supervises.user_id = ? and supervises.state in (?)', user.id, ['accepted', 'changed_user', 'refused']).no_deleted.order('id desc').paginate page: params[:page], per_page: page_size
        
        render_json(@goals, API::Entities::MySuperviseGoalDetail)
      end
      
      # 我关注的目标
      desc "我关注的目标"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :followed_goals do
        user = authenticate!
        
        @goals = user.followed_goals.no_deleted.paginate page: params[:page], per_page: page_size
        
        render_json(@goals, API::Entities::MyFollowingGoalDetail)
      end
      
      # 关注某一个用户
      desc "关注某一个用户"
      params do
        requires :token, type: String, desc: "Token, 必须"
        requires :user_id, type: Integer, desc: "被关注人的id, 必须"
      end
      post '/friendships/create' do
        user = authenticate!
        
        uu = User.find_by(id: params[:user_id])
        if not uu.blank?
          if uu == user
            return { code: 1022, message: "不能关注自己" }
          end
        end
        
        if user.follow(uu)
          Message.create!(actor_id: user.id, user_id: params[:user_id], body:"关注了我", message_type: 4)
          { code: 0, message: "ok" }
        else
          { code: 1011, message: "关注失败" }
        end
        
      end # end follow user
      
      # 取消关注某一个用户
      desc "取消关注某一个用户"
      params do
        requires :token, type: String, desc: "Token, 必须"
        requires :user_id, type: Integer, desc: "被关注人的id, 必须"
      end
      post '/friendships/destroy' do
        user = authenticate!
        
        u = User.find_by(id: params[:user_id])
        if u.blank?
          return { code: 4001, message: "取消关注的用户不存在" }
        end
        
        if user.unfollow(u)
          
          # 发送消息
          if u.push_opened_for?(4)
            msg = (user.nickname || user.mobile) + '对我取消了关注'
            to = []
            to << u.private_token
            PushService.push(msg, to)
          end
          
          { code: 0, message: "ok" }
        else
          { code: 1012, message: "取消关注失败" }
        end
        
      end # end follow user
      
      # 获取粉丝列表
      desc "获取粉丝列表"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :followers do
        user = authenticate!
        
        @followers = []
        @follower_ids = user.followers.order('id DESC').map(&:id)
        @follower_ids.each do |id|
          follower = User.find_by(id: id)
          goal = Goal.no_deleted.where(user_id: id).order('id DESC').first
          hash = follower.as_json
          hash[:goal] = { id: goal.id, title: goal.title || "" } if goal.present?
          @followers << hash
        end
        
        { code: 0, message: "ok", data: @followers }
      end # end get followers
      
      # 获取我关注的用户列表
      desc "获取我关注的用户列表"
      params do
        requires :token, type: String, desc: "Token"
      end
      get :following_users do
        user = authenticate!
        
        @followers = []
        @follower_ids = user.following_users.order('id DESC').map(&:id)
        @follower_ids.each do |id|
          follower = User.find_by(id: id)
          goal = Goal.no_deleted.where(user_id: id).order('id DESC').first
          follower.is_followed = true
          hash = follower.as_json
          hash[:goal] = { id: goal.id, title: goal.title || "" } if goal.present?
          @followers << hash
        end
        
        { code: 0, message: "ok", data: @followers }
      end # end get following_users
      
      # # 赞某个用户的某一目标的某条记录
      # params do
      #   requires :token, type: String, desc: "Token, 必须"
      #   requires :note_id, type: Integer, desc: "记录id, 必须"
      # end
      # post '/likes/create' do
      #   user = authenticate!
      #
      #   if user.like(Note.find_by(id: params[:note_id]))
      #     { code: 0, message: "ok" }
      #   else
      #     { code: 1013, message: "点赞失败" }
      #   end
      # end # end like note
      #
      # # 取消赞某个用户的某一目标的某条记录
      # params do
      #   requires :token, type: String, desc: "Token, 必须"
      #   requires :note_id, type: Integer, desc: "记录id, 必须"
      # end
      # post '/likes/destroy' do
      #   user = authenticate!
      #
      #   if user.unlike(Note.find_by(id: params[:note_id]))
      #     { code: 0, message: "ok" }
      #   else
      #     { code: 1014, message: "取消点赞失败" }
      #   end
      # end # end unlike note
      
      # 获取用户个人资料
      params do
        requires :token, type: String, desc: "Token, 必须"
      end
      
      get :me do
        user = authenticate!
        { code: 0, message: "ok", data: user }
      end # end get me
      
      
      # 更新头像
      params do
        requires :token, type: String, desc: "Token, 必须"
        requires :avatar, desc: "用户头像图片数据，可选"
      end
      
      post :update_avatar do
        user = authenticate!
        
        if params[:avatar]
          user.avatar = params[:avatar]
        end
        
        if user.save
          { code: 0, message: "ok", data: user }
        else
          { code: 1006, message: user.errors.full_messages.join(",") }
        end
        
      end # end update avatar
      
      # 修改用户资料
      params do
        requires :token, type: String, desc: "Token, 必须"
        optional :avatar, desc: "用户头像图片数据，可选"
        optional :nickname, type: String, desc: "用户昵称，可选"
        optional :age, type: Integer, desc: "年龄, 可选"
        optional :gender, type: Integer, desc: "性别，可选"
        optional :constellation, type: String, desc: "星座"
        optional :signature, type: String, desc: "签名"
      end
      
      post :update_profile do
        user = authenticate!
        
        if params[:avatar]
          user.avatar = params[:avatar]
        end
        
        if params[:nickname]
          user.nickname = params[:nickname]
        end
        
        if params[:age]
          user.age = params[:age]
        end
        
        if params[:gender]
          user.gender = params[:gender]
        end
        
        if params[:constellation]
          user.constellation = params[:constellation]
        end
        
        if params[:signature]
          user.signature = params[:signature]
        end
        
        if user.save
          { code: 0, message: "ok", data: user }
        else
          { code: 1006, message: user.errors.full_messages.join(",") }
        end
      end # end update profile
      
      # 获取消息提醒状态
      desc '获取消息提醒状态'
      params do
        requires :token, type: String, desc: "认证Token"
      end
      get :push_settings do
        user = authenticate!
        
        results = []
        
        settings = user.push_settings.split(',')
        User::PUSH_SETTINGS.each_with_index do |s, index|
          results << { id: index + 1, name: s, is_open: settings[index].to_i == 1 ? true : false }
        end
        
        { code: 0, message: "ok", data: results }
        # configs = PushConfig.where(user_id: ).order('id asc')
      end # end get push settings
      
      # 修改消息提醒设置
      desc '修改消息提醒设置'
      params do
        requires :token, type: String, desc: "认证Token"
        requires :push_setting_id, type: Integer, desc: "推送设置id"
        requires :is_open, type: Integer, desc: "是否打开，值为：0或1，0表示关闭，1表示打开"
      end
      post '/push_settings/update' do
        user = authenticate!
        
        unless %w(0 1).include?(params[:is_open].to_s)
          return { code: -1, message: "不正确的参数值，值应为0,1之一" }
        end 
        
        settings = user.push_settings.split(',')
        settings[params[:push_setting_id].to_i - 1] = params[:is_open].to_i
        
        if user.update_attribute(:push_settings, settings.join(','))
          { code: 0, message: "ok" }
        else
          { code: 1130, message: "更新推送设置失败" }
        end
        
      end
      
    end # end user resource
    
  end
end