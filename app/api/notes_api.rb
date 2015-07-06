# coding: utf-8

module API
  class NotesAPI < Grape::API
    
    resource :notes do
      # 发布记录
      desc "创建记录"
      params do
        requires :token, type: String, desc: "Token"
        requires :goal_id, type: Integer, desc: "目标id"
        requires :body, type: String, desc: "记录内容"
        # optional :photos, type: Array do
        #   requires :image, desc: "图片数据"
        # end
      end
      post :create do
        authenticate!
        
        @goal = Goal.find(params[:goal_id])
        
        @note = Note.new
        @note.goal_id = @goal.id
        @note.body = params[:body]
        
        # if params[:photos]
        #   params[:photos].each do |param|
        #     p = Photo.create!(image: param[:image])
        #     @note.photos << p
        #   end
        # end
        # puts params
        
        params.each do |key, value|
          if key.to_s =~ /photo\d+/
            p = Photo.create!(image: value)
            @note.photos << p
          end
        end
        
        if @note.save
          { code: 0, message: "ok" }
        else
          { code: 3001, message: @note.errors.full_messages.join(',') }
        end
        
      end # end create
      
      # 评论记录
      desc "评论记录"
      params do
        requires :token, type: String, desc: "Token"
        requires :body, type: String, desc: "评论的内容"
      end
      post '/:note_id/comment' do
        user = authenticate!
        
        Comment.create!(body: params[:body], user_id: user.id, note_id: params[:note_id])
        { code: 0, message: "ok" }
      end # end comment
      
      # 赞记录
      desc "赞记录"
      params do
        requires :token, type: String, desc: "Token"
      end
      post '/:note_id/like' do
        user = authenticate!
        
        note = Note.find_by(id: params[:note_id])
        if note.blank?
          return { code: 4001, message: "需要点赞的记录不存在" }
        end
        
        if user.like(note)
          { code: 0, message: "ok" }
        else
          { code: 3002, message: "点赞失败" }
        end
      end # end like
      
      # 取消赞记录
      desc "取消赞记录"
      params do
        requires :token, type: String, desc: "Token"
      end
      post '/:note_id/cancel_like' do
        user = authenticate!
        
        if user.unlike(Note.find_by(id: params[:note_id]))
          { code: 0, message: "ok" }
        else
          { code: 3003, message: "取消点赞失败" }
        end
      end # end cancel like
      
    end # end resource 
    
  end
end
