# _*_ coding: utf-8 _*_
class DirController < ApplicationController
  layout 'pasokara_player'
  before_filter :top_tag_load

  def index
    @top_dirs = Directory.paginate(:all, :conditions => ["directory_id is null"], :order => "name", :page => params[:page], :per_page => 50)

    respond_to do |format|
      format.html
      format.xml { render :xml => @top_dirs.to_xml }
      format.json { render :json => @top_dirs.to_json }
    end
  end

  def show
    unless params[:id]
      redirect_to :action => 'index' and return
    end

    @dir = Directory.find(params[:id], :include => :pasokara_files)
    @entities = @dir.entities.paginate(:page => params[:page], :per_page => 50)

    respond_to do |format|
      format.html
      format.xml { render :xml => @entities.to_xml }
      format.json { render :json => @entities.to_json }
    end
  end

end
