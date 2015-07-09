class Note < ActiveRecord::Base
  
  attr_accessor :blike
  
  has_many :photos, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :goal
  
  scope :hot, -> { where('likes_count > 0 or comments_count > 0').order('id DESC') }
  scope :recent, -> { order('id DESC') }
  scope :unsupervise, -> { where('goals.is_supervise = ? and goals.supervisor_id is null', true).order('id DESC') }
  
  def as_json(opts = {})
    {
      id: self.id,
      body: self.body || "",
      photos: self.photos || [],
      likes_count: self.likes_count,
      comments_count: self.comments_count,
      blike: self.blike || false,
      goal_title: self.goal.title || "",
      type: self.goal.category || {},
      owner: self.goal.user || {},      
      published_at: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    }
  end
end
