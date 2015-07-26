module API
  module Entities
    class BaseEntity < Grape::Entity
      format_with(:null) { |v| v.blank? ? "" : v } 
      format_with(:chinese_datetime) { |v| v.blank? ? "" : v.strftime('%Y-%m-%d %H:%M:%S') }
      expose :id
    end
    
    class User < BaseEntity
      expose :mobile, format_with: :null
      expose :nickname, format_with: :null
      expose :private_token, as: :token, format_with: :null
      expose :avatar do |model, opts|
        model.avatar_url
      end
      expose :level do |model, opts|
        model.calcu_level
      end
      expose :signature, format_with: :null
      expose :constellation, format_with: :null
      expose :is_followed do |model, opts|
        model.is_followed || false
      end
    end
    
    class Category < BaseEntity
      expose :name, format_with: :null 
      expose :goals_count
    end
    
    class Note < BaseEntity
      expose :body, format_with: :null
    end
        
    # class Supervise < BaseEntity
    #   expose :user, as: :supervisor, using: API::Entities::User
    # end
    
    class UserGoalDetail < BaseEntity
      expose :title, format_with: :null
      expose :body, format_with: :null
      expose :expired_at, format_with: :chinese_datetime
      expose :category, as: :type, using: API::Entities::Category
      # expose :user, as: :owner, using: API::Entities::User
      expose :is_abandon
      expose :supervisor do |model, opts|
        model.supervisor
      end
    end
    
    # 我的目标
    class MyGoalDetail < BaseEntity
      expose :title, format_with: :null
      # expose :body, format_with: :null
      # expose :expired_at, format_with: :chinese_datetime
      expose :state_intro do |model, opts|
        model.follow_state_intro
      end
      expose :category, as: :type, using: API::Entities::Category
      # expose :user, as: :owner, using: API::Entities::User
      # expose :is_abandon
      expose :supervise_id do |model, opts|
        model.supervise.try(:id) || ""
      end
      expose :state do |model, opts|
        if model.supervise.blank? or !model.is_supervise or model.supervisor_id.blank?
          'normal'
        else
          if model.supervise.accepted
            'accepted'
          else
            'new_request'
          end
        end
      end
      expose :supervise, as: :supervisor do |model, opts|
        if model.supervise.blank?
          {}
        else
          model.supervise.user.as_json
        end
      end
    end
    
    # 我督促的目标
    class MySuperviseGoalDetail < BaseEntity
      expose :title, format_with: :null
      expose :state_intro do |model, opts|
        model.supervise_state_intro
      end
      expose :supervising do |model, opts|
        model.supervising?
      end
      expose :category, as: :type, using: API::Entities::Category
      # expose :user, as: :owner, using: API::Entities::User
    end
    
    # 我关注的目标
    class MyFollowingGoalDetail < BaseEntity
      expose :title, format_with: :null
      expose :state_intro do |model, opts|
        model.follow_state_intro
      end
      expose :supervise, as: :supervisor do |model, opts|
        if model.supervise.blank?
          {}
        else
          model.supervise.user.as_json
        end
      end
      expose :category, as: :type, using: API::Entities::Category
      # expose :user, as: :owner, using: API::Entities::User
    end
    
    class UserDetail < BaseEntity
      expose :mobile, format_with: :null
      expose :nickname, format_with: :null
      expose :avatar do |model, opts|
        model.avatar_url
      end
      expose :level do |model, opts|
        model.calcu_level
      end
      expose :signature, format_with: :null
      expose :gender, format_with: :null
      expose :constellation, format_with: :null
      expose :followers_count, :supervises_count
      expose :is_followed
      expose :completed_goals_count do |model, opts|
        model.goals.where('expired_at <= ?', Time.now).count
      end
      expose :supervise_completed_goals_count do |model, opts|
        model.goals.where('expired_at <= ? and supervisor_id is not null', Time.now).count
      end
      expose :goals, using: API::Entities::MyFollowingGoalDetail do |model, opts|
        model.goals.no_deleted.order('id DESC')
      end
    end
        
    class PhotoDetail < BaseEntity
      expose :image do |model, opts|
        model.image_url
      end
    end
    
    class Goal < BaseEntity
      expose :title, format_with: :null
      expose :body, format_with: :null
      expose :user, as: :owner, using: API::Entities::User
    end
    
    class Comment < BaseEntity
      expose :body, format_with: :null
      expose :user, as: :commenter, using: API::Entities::User
    end
    
    class Reply < BaseEntity
      expose :body, format_with: :null
      expose :user, as: :replyer, using: API::Entities::User
      expose :comment, using: API::Entities::Comment
      expose :created_at, as: :replied_at, format_with: :chinese_datetime
    end
    
    class CommentDetail < BaseEntity
      expose :body, format_with: :null
      expose :created_at, as: :commented_at, format_with: :chinese_datetime
      expose :user, as: :commenter, using: API::Entities::User
      # expose :replies, using: API::Entities::Reply
      expose :at_who do |model, opts|
        model.at_user
      end
    end
    
    class NoteDetail < BaseEntity
      expose :goal, using: API::Entities::Goal
      expose :body, format_with: :null
      expose :photos, using: API::Entities::PhotoDetail
      expose :created_at, as: :published_at, format_with: :chinese_datetime
      expose :likes_count, :comments_count
      expose :blike do |model, opts|
        model.blike || false
      end
      expose :comments, using: API::Entities::CommentDetail
    end

    class GoalNoteDetail < BaseEntity
      expose :body, format_with: :null
      expose :photos, using: API::Entities::PhotoDetail
      expose :likes_count, :comments_count
      expose :created_at, as: :published_at, format_with: :chinese_datetime
    end
    
    class GoalDetail < BaseEntity
      expose :id, :title, :body, :cheers_count, :follows_count
      expose :category, as: :type, using: API::Entities::Category
      expose :user, as: :owner, using: API::Entities::User
      expose :notes, using: API::Entities::GoalNoteDetail do |model, opts|
        model.notes.order('id desc')
      end
      
      expose :is_supervised, :is_cheered, :is_followed
    end
  end
end