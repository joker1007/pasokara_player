class PasokaraController < ApplicationController
  layout 'pasokara_player'

  def queue
    @pasokara = PasokaraFile.find(params[:id])
    QueuedFile.enq @pasokara
    flash[:notice] = "#{@pasokara.name} の予約が完了しました"
    redirect_to :controller => "dir", :action => "show", :id => @pasokara.directory.id
  end

  def search
    @query = params[:query]
    @pasokaras = PasokaraFile.paginate(:all, :conditions => ["fullpath LIKE ?", "%#{@query}%"], :page => params[:page], :per_page => 50, :order => "name")
  end

  def tag_search
    @query = params[:tag].split(" ")
    @pasokaras = PasokaraFile.tagged_with(@query, :on => :tags, :match_all => true).paginate(:page => params[:page], :per_page => 50)
    render :action => 'search'
  end

  def tagging
    @pasokara = PasokaraFile.find(params[:id])
    tags = params[:tags].split(" ")
    @pasokara.tag_list.add tags
    @pasokara.save
    flash[:notice] = @pasokara.tag_list.join(", ")
    redirect_to :controller => "dir", :action => "index"
  end

  def edit_tag
    @pasokara = Pasokara.find(params[:id])
  end

  def remove_tag
    @pasokara = PasokaraFile.find(params[:id])
    tag = params[:tag]
    tag_idx = params[:tag_idx]

    @pasokara.tag_list.remove tag
    @pasokara.save

    if request.xhr?
      render :update do |page|
        page.visual_effect :fade, "tag-#{@pasokara.id}-#{tag_idx}"
      end
    else
      flash[:notice] = "#{@pasokara.name}から#{tag}を削除しました"
      redirect_to :controller => "dir", :action => "index"
    end
  end
end
