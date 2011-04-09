class UsersController < ApplicationController
  layout 'pasokara_player'

  before_filter :no_tag_load
  before_filter :login_required
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

  def new
    @user = User.new
    if request.xhr?
      render :layout => false
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "#{@user.name}を作成しました"
    else
      flash[:error]  = "#{@user.name}を作成できませんでした"
      render :action => 'new'
    end
  end

  def edit
    if request.xhr?
      render :action => "edit", :layout => false
    else
      render :action => "edit"
    end
  end

  def update
    current_user.tweeting = params[:user][:tweeting]
    if current_user.save
      flash[:notice] = "#{current_user.name}の設定が変更されました"
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
      current_user.twitter_access_token = atoken
      current_user.twitter_access_secret = asecret
      current_user.save
      session[:atoken] = atoken
      session[:asecret] = asecret
      flash[:notice] = "Twitter認証が完了しました"
      redirect_to root_path
    else
      flash[:error] = "Twitter認証が確認できませんでした"
      redirect_to root_path
    end
  end

end
