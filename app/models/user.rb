class User < ApplicationRecord
  has_many :searches
  has_many :boroughs, through: :searches
  
end
