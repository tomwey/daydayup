class User < ActiveRecord::Base
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
    }
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