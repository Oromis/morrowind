class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        if user.locked?
          flash[:warning] = I18n.t 'sessions.login.locked'
          redirect_to root_url
        else
          log_in user
          if params[:session][:remember_me] == '1'
            remember user
          else
            forget user
          end
          redirect_back_or user_characters_path user
        end
      else
        flash[:warning] = I18n.t 'sessions.login.not_activated'
        redirect_to root_url
      end
    else
      flash.now[:danger] = I18n.t 'sessions.login.invalid'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
