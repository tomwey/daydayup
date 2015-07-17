class BannersController < ApplicationController
  skip_before_filter :authenticate_admin!, only: :show
  layout :layout_by_action
  
  def layout_by_action
    if action_name == 'show'
      return false
    end
    'application'
  end
  
  def index
    @banners = Banner.order('sort ASC, id DESC')# .paginate page: params[:page], per_page: 30
  end
  
  def show
    @banner = Banner.find(params[:id])
  end
  
  def new
    @banner = Banner.new
  end
  
  def create
    @banner = Banner.new(banner_params)
    
    if @banner.save
      flash[:notice] = '广告创建成功'
      redirect_to banners_path
    else
      render :new
    end
    
  end
  
  def edit
    @banner = Banner.find(params[:id])
  end
  
  def update
    @banner = Banner.find(params[:id])
    
    if @banner.update(banner_params)
      flash[:notice] = '广告修改成功'
      redirect_to banners_path
    else
      render :edit
    end
  end
  
  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to banners_url
  end
  
  def banner_params
    params.require(:banner).permit(:title, :body, :image, :category_id)
  end
  
end