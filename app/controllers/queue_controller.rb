# _*_ coding: utf-8 _*_
class QueueController < ApplicationController
  layout 'pasokara_player'
  before_filter :top_tag_load, :only => [:list]


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
    @extname = File.extname(@pasokara.fullpath)
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

  def last
    @queue = QueuedFile.find(:first, :order => "id desc")

    if @queue
      respond_to do |format|
        format.xml  { render :xml => @queue.pasokara_file.to_xml }
        format.json { render :json => @queue.pasokara_file.to_json }
      end
    else
      render :text => "No Queue", :status => 404
    end
  end

  def deque
    @queue = QueuedFile.deq
    if @queue

      user = @queue.user
      if user and user.tweeting
        begin
          oauth.authorize_from_access(user.twitter_access_token, user.twitter_access_secret)
          client = Twitter::Base.new(oauth)
          client.update("Singing Now: #{@queue.pasokara_file.name}")
        rescue Exception
          logger.warn "#{@queue.user}'s Tweet Failed"
        end
      end

      respond_to do |format|
        format.html
        format.xml { render :xml => @queue.pasokara_file.to_xml }
        format.json { render :json => @queue.pasokara_file.to_json }
      end
    else
      render :text => "No Queue", :status => 404
    end
  end

end
