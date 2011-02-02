# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout "pasokara_player"

  before_filter :no_tag_load

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.erb.html
  def new
    session[:logined_users] ||= []
    @users = User.find(session[:logined_users])
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      session[:logined_users] ||= []
      session[:logined_users].push(user.id) unless session[:logined_users].include? user.id
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "#{user.name}でログインしました"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def switch
    session[:logined_users] ||= []
    user_id = session[:logined_users].find {|i| i == params[:id].to_i}
    if user_id
      user = User.find(user_id)
      self.current_user = user
      flash[:notice] = "#{user.name}でログインしました"
    else
      flash[:error] = "ログインしていません"
    end
    redirect_to login_path
  end

  def destroy
    session[:logined_users] ||= []
    session[:logined_users].delete(current_user.id)
    logout_killing_session!
    flash[:notice] = "ログアウトしました"
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
