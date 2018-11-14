class User < ApplicationRecord
  has_many :searches
  has_many :neighborhoods, through: :searches
  has_many :user_apartments, dependent: :destroy
  has_many :apartments, through: :user_apartments

end
