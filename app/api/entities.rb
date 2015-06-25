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
    end
    
    class Category < BaseEntity
      expose :name, format_with: :null 
      expose :goals_count
    end
    
    class Note < BaseEntity
      expose :body, format_with: :null
    end
    
    class PhotoDetail < BaseEntity
      
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
    
    class NoteDetail < BaseEntity
      expose :goal, using: API::Entities::Goal
      expose :body, format_with: :null
      expose :photos, using: API::Entities::PhotoDetail
      expose :created_at, as: :published_at, format_with: :chinese_datetime
      expose :likes_count, :comments_count
      expose :comments, using: API::Entities::Comment
    end

    class GoalNoteDetail < BaseEntity
      expose :body, format_with: :null
      expose :photos, using: API::Entities::PhotoDetail
      expose :likes_count, :comments_count
      expose :created_at, as: :published_at, format_with: :chinese_datetime
    end
    
    class GoalDetail < BaseEntity
      expose :id, :title, :body
      expose :category, as: :type, using: API::Entities::Category
      expose :user, as: :owner, using: API::Entities::User
      expose :notes, using: API::Entities::GoalNoteDetail do |model, opts|
        model.notes.order('id desc')
      end
      # expose :is_supervised, :is_cheered, :is_followed
    end
  end
end