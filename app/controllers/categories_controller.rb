class CategoriesController < ApplicationController
  
  def index
    @categories = Category.sorted
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:notice] = '创建成功'
      redirect_to categories_path
    else
      render :new
    end
  end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    
    if @category.update(category_params)
      flash[:notice] = '修改成功'
      redirect_to categories_path
    else
      render :edit
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    if @category.goals_count != 0
      flash[:error] = '该类别下面有目标，不能删除'
    else
      @category.destroy
    end
    redirect_to categories_url
  end
  
  private
    def category_params
      params.require(:category).permit(:name, :sort)
    end
  
end