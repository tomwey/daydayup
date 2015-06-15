# coding: utf-8

module API
  class CategoriesAPI < Grape::API
    
    resource :types do
      get do
        @types = Category.sorted
        all = Category.new(id: 0, name: "全部", goals_count: (@types.to_a.sum { |t| t.goals_count }) )
        @types.unshift(all)
        { code: 0, message: "ok", data: @types }
      end
    end # end resource 
    
  end
end
