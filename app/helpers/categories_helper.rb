# coding: utf-8
module CategoriesHelper
  def render_goals_count(category)
    return 0 if category.blank?
    
    if category.name == '全部'
      @types = Category.where('name != ?', '全部')
      return @types.to_a.sum { |t| t.goals_count }
    end
    
    category.goals_count
  end
end