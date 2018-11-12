class Borough < ApplicationRecord
  has_many :incidents, dependent: :destroy
  has_many :searches
  has_many :users, through: :searches

end
