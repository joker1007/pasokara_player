# _*_ coding: utf-8 _*_
class QueueController < ApplicationController
  layout 'pasokara_player'


  def list
    @queue_list = QueuedFile.find(:all, :order => "created_at", :include => :pasokara_file)
    if request.xhr?
      render :update do |page|
        page.replace_html("queue_table", :partial => "list", :object => @queue_list)
      end
    end
  end

  def play
    @queue = QueuedFile.find(:first, :order => "created_at", :include => :pasokara_file)
    
    unless @queue
      render :action => "no_movie" and return
    end

    @pasokara = @queue.pasokara_file
    @extname = File.extname(@pasokara.fullpath_win)
    if @extname =~ /mp4|flv/
      render :layout => false if request.xhr?
    else
      render :text => "Not Flash Movie"
    end
  end

  def remove
    @queue = QueuedFile.find(params[:id])
    @queue.destroy
    redirect_to :action => 'list'
  end

  def deque
    @queue = QueuedFile.find(:first)
    if @queue
      @queue.destroy
    end

    respond_to do |format|
      format.html
    end
  end

end
