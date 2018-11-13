class Neighborhood < ApplicationRecord
  has_many :incidents
  has_many :searches
  has_many :users, through: :searches

  scope :find_by_lonlat, -> (longitude, latitude) { 
    where(%{ 
      ST_Within(ST_SetSRID(ST_MakePoint(%f, %f),4326), geom) 
    } % [longitude, latitude])
  }

end
