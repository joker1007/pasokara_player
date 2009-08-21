class DirController < ApplicationController
  layout 'pasokara_player'

  def index
    @top_dirs = Directory.find(:all, :conditions => ["directory_id is null"], :order => "rootpath, name")
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

    @dir = Directory.find(params[:id])
    sub_dirs = @dir.directories.paginate(:all, :page => params[:page], :per_page => 50)
    pasokara_files = @dir.pasokara_files.paginate(:all, :page => params[:page], :per_page => 50)
    @entities = (sub_dirs + pasokara_files).sort {|a, b| a.name <=> b.name}
    @paging_target = sub_dirs.total_pages > pasokara_files.total_pages ? sub_dirs : pasokara_files
  end

end
