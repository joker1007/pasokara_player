# _*_ coding: utf-8 _*_
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #
  before_filter :icon_size

  protected
  def top_tag_load
    tag_limit = request.mobile? ? 10 : 30
    @tag_list_cache_key = "top_tags_#{tag_limit}"
    unless fragment_exist?(@tag_list_cache_key)
      options = {:limit => tag_limit, :order => "count desc, tags.name asc"}
      @header_tags = PasokaraFile.tag_counts(options)
      @tag_search_url_builder = Proc.new {|t|
        "/tag_search/#{CGI.escape(t.name)}"
      }
    end
    true
  end

  def icon_size
    @icon_size = request.mobile? ? "12x12" : "24x24"
  end
end
