class Reply < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment
  
  validates_presence_of :body
  
  def as_json(opts = {})
    {
      id: self.id,
      body: self.body || "",
      replyer: self.user || {},
      comment: self.comment || {},
      replied_at: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    }
  end
end
