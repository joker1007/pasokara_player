# _*_ coding: utf-8 _*_
class DirController < ApplicationController
  layout 'pasokara_player'
  before_filter :top_tag_load

  def index
    unless fragment_exist?(:action => "index", :page => params[:page])
      @top_dirs = Directory.paginate(:all, :conditions => ["directory_id is null"], :order => "name", :page => params[:page], :per_page => 50)
      @grouping = {}
      @top_dirs.each do |dir|
        @grouping["Root"] ||= []
        @grouping["Root"] << dir
      end
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @grouping.to_xml }
      format.json { render :json => @grouping.to_json }
    end
  end

  def show
    unless params[:id]
      redirect_to :action => 'index' and return
    end

    @dir = Directory.find(params[:id], :include => :pasokara_files)
    unless fragment_exist?(:action => "show", :page => params[:page])
      @entities = @dir.entities.paginate(:page => params[:page], :per_page => 50)
    end
  end

end
