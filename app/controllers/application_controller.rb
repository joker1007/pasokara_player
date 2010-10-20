# _*_ coding: utf-8 _*_
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #
  before_filter :icon_size, :login_check

  protected
  def top_tag_load
    tag_limit = request.mobile? ? 50 : 50
    @tag_list_cache_key = "top_tags_#{tag_limit}"
    unless fragment_exist?(@tag_list_cache_key)
      options = {:limit => tag_limit, :order => "count desc, tags.name asc"}
      @header_tags = PasokaraFile.tag_counts(options)
      @header_tags.each do |tag|
        tag.instance_variable_set(:@query, params[:tag])
        def tag.link_options
          {:controller => "pasokara", :action => "append_search_tag", :append => name, :tag => @query}
        end
      end
    end
    true
  end

  def login_check
    @user = User.find(session[:current_user]) if session[:current_user]
  end

  def icon_size
    @icon_size = request.mobile? ? "12x12" : "24x24"
  end

  def order_options
    order = {:order => "name asc"}
    case params[:sort]
    when "view_count"
      order.merge!({:order => "nico_view_counter desc, name asc"})
    when "view_count_r"
      order.merge!({:order => "nico_view_counter asc, name asc"})
    when "post_new"
      order.merge!({:order => "nico_post desc, created_at desc, name asc"})
    when "post_old"
      order.merge!({:order => "nico_post asc, created_at asc, name asc"})
    when "mylist_count"
      order.merge!({:order => "nico_mylist_counter desc, name asc"})
    end

    order
  end
end
