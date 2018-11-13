class User < ApplicationRecord
  has_many :searches
  has_many :neighborhoods, through: :searches
  
end
