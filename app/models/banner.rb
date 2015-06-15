class Banner < ActiveRecord::Base
  
  def as_json(opts = {})
    {
      id: self.id,
      title: self.title || "",
      link: Setting.upload_url + "/banners/#{self.id}",
    }
  end
  
end
