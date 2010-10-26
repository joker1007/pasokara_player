# _*_ coding: utf-8 _*_
class UserController < ApplicationController
  layout 'pasokara_player'
  
  before_filter :top_tag_load, :only => [:switch, :new, :edit]

  before_filter :login_required, :only => [:edit, :update, :twitter_auth, :twitter_finalize]

  def switch
    @users = User.find(:all)
    if request.xhr?
      render :layout => false
    end
  end

  def new
    @new_user = User.new
    if request.xhr?
      render :layout => false
    end
  end

  def create
    @new_user = User.new(params[:user])
    if @new_user.save
      flash[:notice] = "#{@new_user.name}を作成しました"
      redirect_to root_path
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    @user.tweeting = params[:user][:tweeting]
    if @user.save
      flash[:notice] = "#{@user.name}の設定が変更されました"
    else
      flash[:error] = "設定変更に失敗しました"
    end
    redirect_to root_path
  end

  def twitter_auth
    oauth.set_callback_url(twitter_finalize_url)

    session['rtoken'] = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret

    redirect_to oauth.request_token.authorize_url
  end

  def twitter_finalize
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    profile = Twitter::Base.new(oauth).verify_credentials

    if profile
      atoken = oauth.access_token.token
      asecret = oauth.access_token.secret
      @user.twitter_access_token = atoken
      @user.twitter_access_secret = asecret
      @user.save
      session[:atoken] = atoken
      session[:asecret] = asecret
      flash[:notice] = "Twitter認証が完了しました"
      redirect_to root_path
    else
      flash[:error] = "Twitter認証が確認できませんでした"
      redirect_to root_path
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

  private
  def login_required
    unless session[:current_user]
      flash[:error] = "ログインしていません"
      redirect_to root_path
      return false
    end
    return true
  end
end
