class Photo < ActiveRecord::Base
  belongs_to :note
  
  mount_uploader :image, PhotoUploader
  
  def as_json(opts = {})
    {
      id: self.id,
      image_url: self.image_url,
    }
  end
  
  def image_url
    if self.image.blank?
      ""
    else
      self.image.url(:thumb)
    end
  end
  
end
