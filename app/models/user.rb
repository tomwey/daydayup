class User < ActiveRecord::Base
  
  # 有许多正在关注的用户
  has_many :relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :following_users, through: :relationships, source: :following
  
  # 有许多粉丝
  has_many :reverse_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  
  validates :mobile, presence: true
  validates :mobile, format: { with: /\A1[3|4|5|8][0-9]\d{4,8}\z/, message: "请输入11位正确手机号" }, 
  length: { is: 11 }, :uniqueness => true
  
  validates :nickname, uniqueness: true, allow_nil: true
            
  mount_uploader :avatar, AvatarUploader
  
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
      constellation: self.constellation || "",
      followers_count: self.followers_count,
      following_count: self.following_count,
      
    }
  end
  
  # 粉丝数
  def followers_count
    self.followers.count
  end
  
  # 正在关注的用户数
  def following_count
    self.following_users.count
  end
  
  # 判断是否正在关注某个用户
  def following?(user)
    return false if user.blank?
    relationships.find_by(following_id: user.id)
  end
  
  # 关注
  def follow(user)
    return false if user.blank?
    
    relationships.create(following_id: user.id)
  end
  
  # 取消关注
  def unfollow(user)
    return false if user.blank?
    
    rs = relationships.find_by(following_id: user.id)
    return false if rs.blank?
    
    rs.destroy
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