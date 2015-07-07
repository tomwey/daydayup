class CommentsController < ApplicationController
  def index
    @comments = Comment.includes(:user, :note).order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to comments_url
  end
end