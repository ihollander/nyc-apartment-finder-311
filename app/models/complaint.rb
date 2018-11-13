class Complaint < ApplicationRecord
  # belongs_to :agency
  has_many :incidents, dependent: :destroy

end
