class GoalsController < ApplicationController
  def index
    @goals = Goal.where(visible: true).order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def search
    @goals = Goal.joins(:user).where('title like :keyword or users.nickname like :keyword or users.mobile like :keyword', { keyword: "%#{params[:q]}%" }).where(visible: true).order('id DESC').paginate page: params[:page], per_page: 30
    render :index
  end
  
  def show
    @goal = Goal.includes(:notes).find(params[:id])
    @notes = @goal.notes.order('id desc').paginate page: params[:page], per_page: 30
  end
  
  def destroy
    @goal = Goal.find(params[:id])
    @goal.update_attribute(:visible, false)
    redirect_to goals_url
  end
end