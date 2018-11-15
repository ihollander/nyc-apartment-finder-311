class ApartmentsController < ApplicationController
  before_action :find_apartment, only: [:show, :save_apartment]

  def index
    neighborhood = params["neighborhood"]
    if neighborhood
      Apartment.find_or_create_from_api(neighborhood)
      @apartments = Apartment.joins(:neighborhood).where(neighborhoods: { name: neighborhood })
    else
      @apartments = Apartment.all
    end

  end

  def show
    @value = @apartment.value
    @street = @apartment.street
    @city = @apartment.city
    @state = @apartment.state
    @zipcode = @apartment.zipcode
    @sqft = @apartment.sqft
    @bedrooms = @apartment.bedrooms
    @bathrooms = @apartment.bathrooms
    @year_built = @apartment.year_built
    @images = @apartment.images
    @description = @apartment.description
    @trending = @apartment.price_change
  end

  def save_apartment
    user_apartment = UserApartment.create(user_id: session[:user_id], apartment_id: @apartment.id)
  end

  private

  def find_apartment
    @apartment = Apartment.find_by(id: params[:id])
  end
end
