class UserApartment < ApplicationRecord
  belongs_to :user, depentent: :destroy
  belongs_to :apartment
end
