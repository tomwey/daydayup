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
        ac = AuthCode.where('mobile = ? and code = ? and verified = ?', params[:mobile], params[:code], true).first
        if ac.blank?
          return { code: 1004, message: "验证码无效" }
        end
        
        # 快捷登录
        user = User.find_by(mobile: params[:mobile])
        if user.present?
          ac.update_attribute('verified', false)
          return { code: 0, message: "ok", data: user }
        end
        
        user = User.new(mobile: params[:mobile])
        if user.save
          ac.update_attribute('verified', false)
          { code: 0, message: "ok", data: user }
        else
          { code: 1005, message: "用户登录失败" }
        end
        
      end # end account login
      
    end # end account resource
    
    resource :user do
      
      # 关注某一个用户
      desc "关注某一个用户"
      params do
        requires :token, type: String, desc: "Token, 必须"
        requires :user_id, type: Integer, desc: "被关注人的id, 必须"
      end
      post '/friendships/create' do
        user = authenticate!
        
        if user.follow(User.find_by(id: params[:user_id]))
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
        
        if user.unfollow(User.find_by(id: params[:user_id]))
          { code: 0, message: "ok" }
        else
          { code: 1012, message: "取消关注失败" }
        end
        
      end # end follow user
      
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
      
    end # end user resource
    
  end
end