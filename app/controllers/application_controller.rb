class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  def ensure_logged_in
    unless logged_in?
      store_location
      redirect_to login_url
    else
      @user = current_user
    end
  end

  def ensure_role(role)
    unless current_user && current_user.has_role?(role)
      flash[:danger] = "Du darfst diese Seite nicht besuchen!"
      redirect_to root_url, status: 403
    end
  end
end
