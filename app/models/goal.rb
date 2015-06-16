class Goal < ActiveRecord::Base
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  
  set_rgeo_factory_for_column :location, GEO_FACTORY
  
  validates :title, :expired_at, :presence => true
  
  belongs_to :user
  belongs_to :category, counter_cache: true
  
  has_many :notes, dependent: :destroy
  
  mount_uploader :image, ImageUploader
  
  scope :hot, -> { order('cheers_count desc, follows_count desc, id desc') }
  scope :recent, -> { order('id desc') }
  scope :unsupervise, -> { where(is_supervise: true).order('id desc') }
  
  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      note: self.recent_note,
      type: self.category || {},
      owner: self.user || {},
    }
  end
  
  def self.owner(owner)
    if owner.blank?
      false
    else
      owner.following?(user)
    end
  end
  
  def recent_note
    notes.order('id desc').limit(1)
  end
  
end

# t.string :title, :null => false
# t.text :body
# t.datetime :expired_at
# t.point :location, geographic: true
# t.integer :category_id
# t.integer :user_id
# t.boolean :is_supervise, default: true
# t.string :image
