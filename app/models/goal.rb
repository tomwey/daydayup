class Goal < ActiveRecord::Base
  GEO_FACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  
  set_rgeo_factory_for_column :location, GEO_FACTORY
  
  validates :title, :expired_at, :presence => true
  
  belongs_to :user
  belongs_to :category, counter_cache: true
end

# t.string :title, :null => false
# t.text :body
# t.datetime :expired_at
# t.point :location, geographic: true
# t.integer :category_id
# t.integer :user_id
# t.boolean :is_supervise, default: true
