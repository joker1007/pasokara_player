# _*_ coding: utf-8 _*_
class DirController < ApplicationController
  layout 'pasokara_player'
  caches_page :index, :show

  def index
    @top_dirs = Directory.find(:all, :conditions => ["directory_id is null"], :order => "rootpath, name", :include => [:directories, :pasokara_files])
    @grouping = {}
    @top_dirs.each do |dir|
      @grouping[dir.rootpath] ||= []
      @grouping[dir.rootpath] << dir
    end
  end

  def show
    unless params[:id]
      redirect_to :action => 'index' and return
    end

    @dir = Directory.find(params[:id], :include => [:directories, :pasokara_files])
    @entities = @dir.entities.paginate(:page => params[:page], :per_page => 50)
  end

end
