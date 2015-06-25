class Note < ActiveRecord::Base
  
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :goal
  
  def as_json(opts = {})
    {
      id: self.id,
      body: self.body || "",
      photos: self.photos || [],
      likes_count: self.likes_count,
      comments_count: self.comments_count,
      blike: false,
      published_at: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    }
  end
end
