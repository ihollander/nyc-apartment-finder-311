class Agency < ApplicationRecord
  has_many :incidents, dependent: :destroy
  # has_many :complaints, dependent: :destroy

end
