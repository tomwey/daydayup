# coding: utf-8

module API
  class GoalsAPI < Grape::API
    
    resource :goals do
      params do
        requires :type_id, type: Integer, desc: "类别ID"
        optional :token, type: String, desc: "认证Token"
      end
      get '/:filter' do
        @type = Category.find_by(id: params[:type_id])
        if @type.blank?
          return { code: -100, message: "没有找到该类别" }
        end
        
        @goals = Goal.send(params[:filter].to_sym)
        if @type.name != '全部'
          @goals = @goals.where(category_id: @type.id)
        end
        
        @goals = @goals.paginate(page: params[:page], per_page: page_size).all
        
        user = User.find_by(private_token: params[:token])
        @goals = @goals.owner(user)
        
        { code: 0, message: 'ok', data: @goals }
      end
    end # end resource 
    
  end
end
