# _*_ coding: utf-8 _*_
class TagController < ApplicationController
  layout "pasokara_player"

  before_filter :top_tag_load

  def list
    options = {:order => "count desc, tags.name asc"}
    @tags = PasokaraFile.tag_counts(options).paginate(:page => params[:page], :per_page => per_page)
  end

  def search
    options = {:order => "count desc, tags.name asc"}
    options.merge!({:conditions => ["tags.name LIKE ?", "%#{params[:tag]}%"]})
    @tags = PasokaraFile.tag_counts(options).paginate(:page => params[:page], :per_page => per_page)
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html "entity_list", :partial => "search"
          page.visual_effect :highlight, "entity_list", :duration => 0.5
        end
      }
    end
  end

  private
  def per_page
    100
  end

end
