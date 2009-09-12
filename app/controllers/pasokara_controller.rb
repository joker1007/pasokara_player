# _*_ coding: utf-8 _*_
class PasokaraController < ApplicationController
  layout 'pasokara_player'

  def queue
    @pasokara = PasokaraFile.find(params[:id])
    QueuedFile.enq @pasokara
    flash[:notice] = "#{@pasokara.name} の予約が完了しました"
    redirect_to root_path
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
    count = @pasokara.tag_list.size
    @pasokara.tag_list.add tags
    @pasokara.save
    if request.xhr?
      render :update do |page|
        tag_idx = 0
        tags.each do |tag|
          page.insert_html :bottom, "tag-line-box-#{@pasokara.id}", tag_line_edit(@pasokara, tag, count+tag_idx+1)
        end
      end
    else
      flash[:notice] = @pasokara.tag_list.join(", ")
      redirect_to :controller => "dir", :action => "index"
    end
  end

  def open_tag_form
    @pasokara = PasokaraFile.find(params[:id])
    render :update do |page|
      page.replace "tag-list-#{@pasokara.id}", tag_list_edit(@pasokara)
    end
  end

  def close_tag_form
    @pasokara = PasokaraFile.find(params[:id])
    render :update do |page|
      page.replace "tag-list-#{@pasokara.id}", tag_list(@pasokara)
    end
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

  def all_tag
    render :update do |page|
      page.replace "all_tag_list", all_tag_list(:order => "count desc")
    end
  end
end
