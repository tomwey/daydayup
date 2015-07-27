class Room < ActiveRecord::Base
  belongs_to :sponsor, class_name: "User", foreign_key: "sponsor_id"
  belongs_to :audience, class_name: "User", foreign_key: "audience_id"
  has_many :talks, dependent: :destroy
end
