class DlFeedsController < ApplicationController
  layout "pasokara_player"

  before_filter :no_tag_load

  # GET /dl_feeds
  # GET /dl_feeds.xml
  def index
    @dl_feeds = DlFeed.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dl_feeds }
    end
  end

  # GET /dl_feeds/1
  # GET /dl_feeds/1.xml
  def show
    @dl_feed = DlFeed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dl_feed }
    end
  end

  # GET /dl_feeds/new
  # GET /dl_feeds/new.xml
  def new
    @dl_feed = DlFeed.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dl_feed }
    end
  end

  # GET /dl_feeds/1/edit
  def edit
    @dl_feed = DlFeed.find(params[:id])
  end

  # POST /dl_feeds
  # POST /dl_feeds.xml
  def create
    @dl_feed = DlFeed.new(params[:dl_feed])

    respond_to do |format|
      if @dl_feed.save
        flash[:notice] = 'DlFeed was successfully created.'
        format.html { redirect_to(@dl_feed) }
        format.xml  { render :xml => @dl_feed, :status => :created, :location => @dl_feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dl_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dl_feeds/1
  # PUT /dl_feeds/1.xml
  def update
    @dl_feed = DlFeed.find(params[:id])

    respond_to do |format|
      if @dl_feed.update_attributes(params[:dl_feed])
        flash[:notice] = 'DlFeed was successfully updated.'
        format.html { redirect_to(@dl_feed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dl_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dl_feeds/1
  # DELETE /dl_feeds/1.xml
  def destroy
    @dl_feed = DlFeed.find(params[:id])
    @dl_feed.destroy

    respond_to do |format|
      format.html { redirect_to(dl_feeds_url) }
      format.xml  { head :ok }
    end
  end
end
