# coding: utf-8

module API
  class GoalsAPI < Grape::API
    
    resource goals do
      params do
        requires :type_id, type: Integer, desc: "类别ID"
      end
      get do
        @banners = Banner.where(category_id: params[:type_id]).order('id DESC')
        
        { code: 0, message: "ok", data: @banners }
      end
    end # end resource 
    
  end
end
