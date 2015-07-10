class Banner < ActiveRecord::Base
  
  validates_presence_of :image, :category_id
  
  mount_uploader :image, ImageUploader
  
  belongs_to :category
  
  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      image_url: self.image_url,
      link: Setting.upload_url + "/banners/#{self.id}",
    }
  end
  
  def image_url
    if self.image
      self.image.url(:large)
    else
      ""
    end
  end
  
end
