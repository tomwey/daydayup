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
      goal_title: self.title || "",
      note: self.recent_note || {},
      type: self.category || {},
      owner: self.user || {},
      need_supervise: self.is_supervise,
      is_supervised: self.is_supervised?,
      supervisor: self.supervisor,
      is_cheered: self.is_cheered || false,
      is_followed: self.is_followed || false,
      latitude: latitude,
      longitude: longitude,
      published_at: self.created_at.strftime('%Y-%m-%d %H:%M:%S'),
    }
  end
  
  def supervisor
    u = User.find_by(id: self.supervisor_id)
    if u.blank?
      {}
    else
      u.as_json
    end
  end
  
  def supervisor_changed?
    self.supervisor_id.blank? or self.supervisor_id.to_i != self.supervise.try(:user_id)
  end
  
  def completed?
    ( !self.is_abandon and self.expired_at < Time.now )
  end
  
  def supervising?
    if self.supervise.blank?
      return false
    end
    
    ( !self.is_abandon and !completed? and !supervisor_changed? )
    
  end
  
  def supervise_state_intro
    msg = if self.is_abandon
      "目标失败，督促结束"
    elsif self.completed?
      "已完成，督促成功"
    elsif self.supervisor_changed?
      "已更换督促人"
    else
      '到期时间：' + self.expired_at.strftime('%Y.%m.%d')
    end
    msg
    
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
