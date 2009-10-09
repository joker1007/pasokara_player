class UserController < ApplicationController
  layout 'pasokara_player'

  def switch
    @users = User.find(:all)
  end

  def login
    id = params[:id]
    @user = User.find(id)
    session[:current_user] = id
    flash[:notice] = "#{@user.name}でログインしました"
    redirect_to root_path
  end

  def logout
    session[:current_user] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to root_path
  end
end
