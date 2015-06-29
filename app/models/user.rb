class User < ActiveRecord::Base
  
  attr_accessor :is_followed
  
  # 有许多正在关注的用户
  has_many :relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :following_users, through: :relationships, source: :following
  
  # 有许多粉丝
  has_many :reverse_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  
  has_many :goals, dependent: :destroy
  
  has_many :follows, dependent: :destroy
  has_many :followed_goals, through: :follows, source: :goal
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8|7][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  validates :nickname, uniqueness: true, allow_nil: true
            
  mount_uploader :avatar, AvatarUploader
  
  scope :goal_geek, -> {  }
  scope :supervise_geek, -> { order('supervises_count desc') }
  scope :popular_geek, -> { order('followers_count desc') }
  
  after_create :generate_private_token
  def generate_private_token
    random_key = "#{SecureRandom.hex(10)}"
    self.update_attribute(:private_token, random_key)
  end
  
  def as_json(opts = {})
    {
      id: self.id,
      mobile: self.mobile || "",
      nickname: self.nickname || "",
      token: self.private_token || "",
      avatar: self.avatar_url,
      gender: self.gender || "",
      age: self.age || "",
      level: self.calcu_level,
      signature: self.signature || "",
      constellation: self.constellation || "",
      followers_count: self.followers_count,
      following_count: self.following_count,
      supervises_count: self.supervises_count,
      is_followed: self.is_followed || false,
    }
  end
  
  # # 粉丝数
  # def followers_count
  #   self.followers.count
  # end
  #
  # # 正在关注的用户数
  # def following_count
  #   self.following_users.count
  # end
  
  # 判断是否正在关注某个用户
  def following?(user)
    return false if user.blank?
    relationships.find_by(following_id: user.id).present?
  end
  
  # 关注
  def follow(user)
    return false if user.blank?
    
    relationships.create!(following_id: user.id)
    
    self.update_attribute(:following_count, self.following_count + 1)
    user.update_attribute(:followers_count, user.followers_count + 1)
  end
  
  # 取消关注
  def unfollow(user)
    return false if user.blank?
    
    rs = relationships.find_by(following_id: user.id)
    return false if rs.blank?
    
    rs.destroy
    
    self.update_attribute(:following_count, self.following_count - 1) if (self.following_count - 1) >= 0
    user.update_attribute(:followers_count, user.followers_count - 1) if (user.followers_count - 1) >= 0
  end
  
  # 点赞记录
  def like(note)
    return false if note.blank?
    
    Like.create(user_id: self.id, note_id: note.id)
  end
  
  # 取消点赞
  def unlike(note)
    return false if note.blank?
    
    like = Like.where(user_id: self.id, note_id: note.id).first
    return false if like.blank?
    
    like.destroy
  end
  
  # 关注目标
  def follow_goal(goal)
    return false if goal.blank?
    
    Follow.create(user_id: self.id, goal_id: goal.id)
  end
  
  # 判断是否正在关注某个目标
  def following_goal?(goal)
    return false if goal.blank?
    Follow.where(user_id: user.id, goal_id: goal.id).count > 0
  end
  
  # 取消关注目标
  def unfollow_goal(goal)
    return false if goal.blank?
    
    follow = Follow.where(user_id: self.id, goal_id: goal.id).first
    return false if follow.blank?
    
    follow.destroy
  end
  
  # 加油目标
  def cheer(goal)
    return false if goal.blank?
    
    Cheer.create(user_id: self.id, goal_id: goal.id)
  end
  
  # 取消加油目标
  def uncheer(goal)
    return false if goal.blank?
    
    cheer = Cheer.where(user_id: self.id, goal_id: goal.id).first
    return false if cheer.blank?
    
    cheer.destroy
  end
  
  # 更新督促目标数
  def change_supervises_count(n)
    self.update_attribute(:supervises_count, self.supervises_count + n) if ( self.supervises_count + n ) >= 0
  end
  
  def calcu_level
    "LV1"
  end
  
  def avatar_url
    if self.avatar.present?
      self.avatar.url(:big)
    else
      ""
    end
  end
end

# gender, :integer, default: 1 # 1 表示男，2 表示女，3 表示其他
# age, :integer
# level, :integer # 级别
# constellation, :string # 星座