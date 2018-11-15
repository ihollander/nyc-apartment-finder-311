class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]
  before_action :current_user, only: [:show, :edit, :update, :destroy]
  before_action :set_minute_options, only: [:new, :edit]

  # get '/register'
  def new
    # show new user form
    @user = User.new
  end

  # post '/register'
  def create
    user = User.create(user_params)
    if user.valid?
      login_user(user)
      redirect_to neighborhoods_path
    else
      flash[:errors] = user.errors.full_messages
      redirect_to register_path
    end
  end

  # get '/profile'
  def show
    # show user profile
  end

  # get '/profile/edit'
  def edit
    # render edit form
  end

  # patch '/profile/edit'
  def update
    @user.update(user_params)
    if @user.valid?
      redirect_to profile_path
    else
      flash[:errors] = @user.errors.full_messages
      redirect_to edit_profile_path
    end
  end

  # delete '/profile'
  def destroy
    @user.destroy
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :username, 
      :password,
      :password_confirmation,
      :work_address,
      :commute_time
    )
  end

  def set_minute_options
    @minute_options = [15,30,45,60]
  end
end

# 