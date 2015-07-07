class GoalsController < ApplicationController
  def index
    @goals = Goal.where(visible: true).order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def show
    @goal = Goal.find(params[:id])
  end
  
  def destroy
    @goal = Goal.find(params[:id])
    @goal.update_attribute(:visible, false)
    redirect_to goals_url
  end
end