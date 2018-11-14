class SessionsController < ApplicationController
  skip_before_action :authorized

  # get '/'
  def new
    # show login form
  end

  # post '/login'
  def create 
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      login_user(user)
      redirect_to neighborhoods_path
    else
      flash[:errors] = ["Invalid username or password"]
      redirect_to root_path
    end
  end

  # delete '/logout'
  def destroy
    session.delete(:user_id)
    redirect_to root_path
  end
end