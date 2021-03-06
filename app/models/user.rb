class User < ApplicationRecord
  belongs_to :neighborhood
  has_many :user_apartments, dependent: :destroy
  has_many :apartments, through: :user_apartments
  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :work_address, presence: { message: "Work Address not found in New York dataset" }

  # validate :must_be_new_york_address 

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  # def must_be_new_york_address
  #   if work_address.present?
  #     if Neighborhood.find_by_lonlat(self.longitude, self.latitude).count == 0
  #       errors.add(:work_address, "not found New York dataset")
  #     end
  #   end
  # end

  # custom setter: calls GoogleApi and gets formatted address
  def work_address=(work_address)
    api_client = GoogleApi::MapsClient.new
    response_json = api_client.geocode(work_address)
    if response_json && response_json["status"] != "ZERO_RESULTS"
      neighborhood = Neighborhood.find_by_address(response_json["results"][0]["formatted_address"])
      if neighborhood
        # call super to override setter method...
        super(response_json["results"][0]["formatted_address"])
        self.latitude = response_json["results"][0]["geometry"]["location"]["lat"].to_f
        self.longitude = response_json["results"][0]["geometry"]["location"]["lng"].to_f
        self.neighborhood = neighborhood
      end
    else
      super(nil)
      self.latitude = nil
      self.longitude = nil
      self.neighborhood = nil
    end
  end

end
