class MessagesController < ApplicationController
  def index
    @messages = Message.order('id DESC').paginate page: params[:page], per_page: 30
  end
  
  def new
    @message = Message.new
  end
  
  def create
    @message = Message.new(message_params)
    if @message.save
      flash[:notice] = '系统消息创建成功'
      redirect_to messages_path
    else
      render :new
    end
  end
  
  def message_params
    params.require(:message).permit(:body)
  end
  
end