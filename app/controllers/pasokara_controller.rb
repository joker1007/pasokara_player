# _*_ coding: utf-8 _*_
class PasokaraController < ApplicationController
  layout 'pasokara_player'
  before_filter :top_tag_load, :except => [:tag_search]
  before_filter :related_tag_load, :only => [:tag_search]

  def queue
    @pasokara = PasokaraFile.find(params[:id])
    QueuedFile.enq @pasokara
    flash[:notice] = "#{@pasokara.name} の予約が完了しました"
    redirect_to root_path
  end

  def show
    @pasokara = PasokaraFile.find(params[:id])
    if request.xhr?
      render :update do |page|
        page.insert_html :after, "tag-list-#{params[:id]}", info_list(@pasokara)
        page.replace "show-info-#{params[:id]}", ""
      end
    else
      respond_to do |format|
        format.html
        format.xml { render :xml => @pasokara.to_xml }
        format.json { render :json => @pasokara.to_json }
      end
    end
  end

  def thumb
    @pasokara = PasokaraFile.find(params[:id])
    thumb_file = @pasokara.thumb_file.gsub(/\//, "\\").tosjis
    if File.exist?(thumb_file)
      send_file(thumb_file, :filename => "#{params[:id]}.jpg", :disposition => "inline", :type => "image/jpeg")
    else
      send_file("#{RAILS_ROOT}/public/images/noimg-1_3.gif", :disposition => "inline", :type => "image/gif")
    end
  end

  def movie
    @pasokara = PasokaraFile.find(params[:id])
    movie_file = @pasokara.fullpath_of_computer
    extname = File.extname(movie_file)
    if extname =~ /mp4|flv/
      send_file(movie_file, :filename => "#{params[:id]}#{extname}")
    else
      render :text => "Not Flash Movie", :status => 404
    end
  end

  def preview
    @pasokara = PasokaraFile.find(params[:id])
    render :layout => false if request.xhr?
  end

  def search
    @query = params[:query].respond_to?(:force_encoding) ? params[:query].force_encoding(Encoding::UTF_8) : params[:query]
    unless fragment_exist?(:query => @query, :page => params[:page])
      query_words = @query.split(/[\s　]/)
      conditions = query_words.inject([""]) {|cond_arr, query| cond_arr[0] += "name LIKE ? AND "; cond_arr << "%#{query}%"}
      conditions[0] = conditions[0][0..-6]
      @pasokaras = PasokaraFile.find(:all, :conditions => conditions, :order => "name")
      @pasokaras += PasokaraFile.tagged_with(query_words, :on => :tags, :match_all => true, :order => "name")
      @pasokaras.sort! {|a, b| a.name <=> b.name }
      @pasokaras.uniq!
      @pasokaras = @pasokaras.paginate(:page => params[:page], :per_page => 50)
    end
  end

  def tag_search
    @query = params[:tag].respond_to?(:force_encoding) ? params[:tag].force_encoding(Encoding::UTF_8) : params[:tag]
    @tag_words = @query.split(/\+|\s/)
    remove_tag = params[:remove].respond_to?(:force_encoding) ? params[:remove].force_encoding(Encoding::UTF_8) : params[:remove]
    if remove_tag
      @tag_words.delete remove_tag
      if @tag_words.empty?
        redirect_to(root_path) and return
      else
        redirect_to(:action => "tag_search", :tag => @tag_words.join("+")) and return
      end
    end

    unless fragment_exist?(:query => @query, :page => params[:page])
      @pasokaras = PasokaraFile.tagged_with(@tag_words, :on => :tags, :match_all => true, :order => "name").find(:all).paginate(:page => params[:page], :per_page => 50)
      
    end
    render :action => 'search'
  end

  def append_search_tag
    tag = params[:tag].split(/\+|\s/).push(params[:append]).join("+")
    redirect_to :action => "tag_search", :tag => tag
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

  protected
  def related_tag_load
    @query = params[:tag].respond_to?(:force_encoding) ? params[:tag].force_encoding(Encoding::UTF_8) : params[:tag]
    @tag_words = @query.split("+")

    tag_limit = request.mobile? ? 10 : 30
    @tag_list_cache_key = "#{@query}_related_tags_#{tag_limit}"
    unless fragment_exist?(@tag_list_cache_key)
      @header_tags = PasokaraFile.related_tags(@tag_words, tag_limit)
      @tag_search_url_builder = Proc.new {|t|
        "/pasokara/append_search_tag?tag=#{ERB::Util.u(@query)}&append=#{ERB::Util.u(t.name)}"
      }
    end
  end
end
