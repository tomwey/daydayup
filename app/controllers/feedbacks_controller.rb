class FeedbacksController < ApplicationController
  def index
    @feedbacks = Feedback.order('id DESC').paginate page: params[:page], per_page: 30
  end
  
end