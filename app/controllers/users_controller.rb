class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :gm_user,        only: [:index]
  before_action :admin_user,     only: [:destroy]

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = I18n.t('users.create.account_activation.flash')
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profil aktualisiert"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Benutzer gelöscht"
    redirect_to users_url
  end

  private
    def user_params
      if current_user && current_user.admin?
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :theme, :role)
      else
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :theme)
      end
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Bitte einloggen."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def gm_user
      redirect_to(root_url) unless current_user.has_role?(:gm)
    end
end
