# _*_ coding: utf-8 _*_
class UserController < ApplicationController
  layout 'pasokara_player'

  def switch
    @users = User.find(:all)
    if request.xhr?
      render :layout => false
    end
  end

  def new
    @user = User.new
    if request.xhr?
      render :layout => false
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "#{@user.name}を作成しました"
      redirect_to root_path
    else
      render :action => "new"
    end
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
