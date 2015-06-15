class Category < ActiveRecord::Base
  
  validates_presence_of :name
  
  scope :sorted, -> { order('sort ASC, id DESC') }
  
  def as_json(opts = {})
    {
      id: self.id,
      name: self.name || "",
      goals_count: self.goals_count,
    }
  end
end
