# coding: utf-8

module API
  class CategoriesAPI < Grape::API
    
    resource :types do
      get do
        @types = Category.where('name != ?', '全部').sorted
        all = Category.find_by(name: '全部')
        unless all.blank?
          all.goals_count = @types.to_a.sum { |t| t.goals_count }
          @types.unshift(all)
        end
        
        { code: 0, message: "ok", data: @types }
      end
    end # end resource 
    
  end
end
