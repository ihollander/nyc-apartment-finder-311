class UserApartment < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :apartment

  validates :apartment, uniqueness: { scope: :user }
end
