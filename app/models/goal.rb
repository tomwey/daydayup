class Goal < ActiveRecord::Base
  
  attr_accessor :is_cheered, :is_followed
  
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  
  set_rgeo_factory_for_column :location, GEO_FACTORY
  
  validates :title, :expired_at, :presence => true
  
  belongs_to :user
  belongs_to :category, counter_cache: true
  
  has_many :notes, dependent: :destroy
  has_many :cheers
  
  has_one :supervise
  
  mount_uploader :image, ImageUploader
  
  scope :no_deleted, -> { where(visible: true) }
  scope :no_abandon, -> { no_deleted.where(is_abandon: false) }
  scope :hot, -> { no_abandon.order('cheers_count desc, follows_count desc, id desc') }
  scope :recent, -> { no_abandon.order('id desc') }
  scope :unsupervise, -> { no_abandon.where('is_supervise = ? and supervisor_id is null', true).order('id desc') }
  
  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      note: self.recent_note || {},
      type: self.category || {},
      owner: self.user || {},
      is_supervised: self.is_supervised?,
      is_cheered: self.is_cheered || false,
      is_followed: self.is_followed || false,
      latitude: latitude,
      longitude: longitude,
    }
  end
  
  def is_supervised?
    self.supervisor_id.present?
    # supervise = Supervise.where(goal_id: self.id, accepted: true).first
    # !!supervise
  end
  
  def supervisor_name
    User.find_by(id: self.supervisor_id).try(:nickname) || '-'
  end
  
  def latitude
    if location
      location.y || ""
    else
      ""
    end
  end
  
  def longitude
    if location
      location.x || ""
    else
      ""
    end
  end
  
  def self.owner(owner)
    if owner.blank?
      false
    else
      owner.following?(user)
    end
  end
  
  def recent_note
    notes.order('id desc').first
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
