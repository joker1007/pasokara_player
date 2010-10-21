# _*_ coding: utf-8 _*_
class PasokaraController < ApplicationController
  layout 'pasokara_player'
  before_filter :top_tag_load, :except => [:tag_search, :solr_search, :thumb]
  before_filter :related_tag_load, :only => [:tag_search]

  def list
    @pasokaras = PasokaraFile.find(:all, :select => "id, name, nico_name, duration")
    respond_to do |format|
      format.xml {render :xml => @pasokaras.to_xml}
      format.json {render :json => @pasokaras.to_json}
      format.text {render :text => @pasokaras.map {|pasokara| pasokara.nico_name }.compact.join("\n")}
    end
  end

  def queue
    if params[:id] =~ /^\d+$/
      @pasokara = PasokaraFile.find(params[:id])
    elsif params[:id] =~ /sm\d+/
      @pasokara = PasokaraFile.find_by_nico_name(params[:id])
    else
      render :text => "パラメーターが不正です。", :status => 404 and return
    end
    QueuedFile.enq @pasokara, session[:current_user]
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
    expires_in(8.hours, :public => true)
    if data = CACHE[params[:id]]
      send_data(data, :filename => "#{params[:id]}.jpg", :disposition => "inline", :type => "image/jpeg")
    else
      send_file("#{RAILS_ROOT}/public/images/noimg-1_3.gif", :disposition => "inline", :type => "image/gif")
    end
  end

  # 要修正
  def movie
    @pasokara = PasokaraFile.find(params[:id])
    movie_file = @pasokara.fullpath
    extname = File.extname(movie_file)
    if File.exist?(movie_file) and extname =~ /mp4|flv/
      send_file(movie_file, :filename => "#{params[:id]}#{extname}", :x_sendfile => true)
    else
      render :text => "Not Flash Movie", :status => 404
    end
  end

  def preview
    @pasokara = PasokaraFile.find(params[:id])
    extname = File.extname(@pasokara.fullpath)
    if File.exist?(@pasokara.fullpath) and extname =~ /mp4|flv/
      render :layout => false
    else
      render :text => "Not Flash Movie", :status => 404
    end
  end

  def search
    @query = params[:query].respond_to?(:force_encoding) ? params[:query].force_encoding(Encoding::UTF_8) : params[:query]
    unless fragment_exist?(:query => @query, :page => params[:page])
      query_words = @query.split(/[\s　]/)
      conditions = query_words.inject([""]) {|cond_arr, query| cond_arr[0] += "name LIKE ? AND "; cond_arr << "%#{query}%"}
      conditions[0] = conditions[0][0..-6]

      order = order_options

      @pasokaras = PasokaraFile.union([{:conditions => conditions}.merge(pasokara_files_select), PasokaraFile.find_options_for_find_tagged_with(query_words, {:on => :tags, :match_all => true, :order => "name"}.merge(pasokara_files_select))], order)

      @pasokaras = @pasokaras.paginate(:page => params[:page], :per_page => per_page)
    end
  end

  def solr_search
    @query = params[:query].respond_to?(:force_encoding) ? params[:query].force_encoding(Encoding::UTF_8) : params[:query]
    @filters = (params[:filter] || "").split(/\+/)
    solr_query = set_solr_query(@query)

    @solr = Solr::Connection.new("http://#{SOLR_SERVER}/solr")

    page = params[:page].nil? ? 1 : params[:page].to_i

    prm = {
      :start => (page - 1) * 50,
      :rows => per_page,
      :sort => solr_order_options,
      :field_list => [:id, :name, :nico_name, :nico_view_counter, :nico_comment_num, :nico_mylist_counter, :nico_post, :duration],
      :filter_queries => @filters,
      :facets => {:fields => [:tag], :limit => 50, :mincount => 1}
    }

    res = @solr.query(solr_query, prm)

    unless fragment_exist?(:query => solr_query, :filter => params[:filter], :field => params[:field], :page => params[:page], :sort => params[:sort])
      @pasokaras = WillPaginate::Collection.new(page, per_page)
      res.hits.each do |result|
        pasokara = PasokaraFile.new(result)
        pasokara.id = result["id"]
        @pasokaras << pasokara
      end

      @pasokaras.total_entries = res.total_hits
    end

    @tag_list_cache_key = "solr_tag_#{solr_query}_#{params[:filter]}_#{params[:field]}"
    unless fragment_exist?(@tag_list_cache_key)

      facets = res.field_facets("tag")

      # ヘルパーメソッド向けにインターフェースを合わせる
      facets.each do |facet|
        facet.instance_variable_set(:@filters, @filters)
        facet.instance_variable_set(:@query, @query)
        facet.instance_variable_set(:@field, params[:field])
        facet.instance_eval do
          def count; self["value"]; end
          def link_options
            {:controller => "pasokara", :action => "solr_search", :query => @query, :field => @field, :filter => @filters.join("+") + "+tag:#{name}"}
          end
        end
      end

      @header_tags = facets
    end
    render :action => 'search'
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

    unless fragment_exist?(:query => @query, :page => params[:page], :sort => params[:sort])
      find_options = {:on => :tags, :match_all => true, :order => "name"}

      order = order_options

      find_options.merge!(order)

      @pasokaras = PasokaraFile.tagged_with(@tag_words, find_options).find(:all, pasokara_files_select).paginate(:page => params[:page], :per_page => per_page)
      
    end
    render :action => 'search'
  end

  def related_search
    @query = params[:id].respond_to?(:force_encoding) ? params[:id].force_encoding(Encoding::UTF_8) : params[:id]
    @pasokaras = PasokaraFile.related_files(@query.to_i, 30).paginate(:page => params[:page], :per_page => per_page)
    render :action => 'search'
  end

  def append_search_tag
    current_tags = params[:tag] || ""
    tag = current_tags.split(/\+|\s/).push(params[:append]).join("+")
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

    tag_limit = request.mobile? ? 50 : 50
    @tag_list_cache_key = "#{@query}_related_tags_#{tag_limit}"
    unless fragment_exist?(@tag_list_cache_key)
      @header_tags = PasokaraFile.related_tags(@tag_words, tag_limit)
      @header_tags.each do |tag|
        tag.instance_variable_set(:@query, params[:tag])
        def tag.link_options
          {:controller => "pasokara", :action => "append_search_tag", :append => name, :tag => @query}
        end
      end
    end
  end

  def pasokara_files_select
    {:select => "pasokara_files.id, pasokara_files.name, pasokara_files.nico_name, pasokara_files.nico_post, pasokara_files.nico_view_counter, pasokara_files.nico_comment_num, pasokara_files.nico_mylist_counter, pasokara_files.duration, pasokara_files.created_at"}
  end

  def set_solr_query(query)
    words = query.split(/\s+/)
    case params[:field]
    when "n"
      solr_query = words.join(" AND ")
    when "t"
      solr_query = words.map {|w| "tag:#{w}"}.join(" AND ")
    when "d"
      solr_query = words.map {|w| "nico_description:#{w}"}.join(" AND ")
    when "r"
      solr_query = @query
    when "a"
      solr_query_temp = []
      solr_query_temp << words.map {|w| "name:#{w}"}.join(" AND ")
      solr_query_temp << words.map {|w| "tag:#{w}"}.join(" AND ")
      solr_query_temp << words.map {|w| "nico_description:#{w}"}.join(" AND ")
      solr_query = solr_query_temp.map {|q| "(#{q})"}.join(" OR ")
    else
      solr_query = words.join(" AND ")
    end
    solr_query
  end

  def solr_order_options
    order = [{:name_str => :ascending}]
    case params[:sort]
    when "view_count"
      order = [{:nico_view_counter => :descending}]
    when "view_count_r"
      order = [{:nico_view_counter => :ascending}]
    when "post_new"
      order = [{:nico_post => :descending}]
    when "post_old"
      order = [{:nico_post => :ascending}]
    when "mylist_count"
      order = [{:nico_mylist_counter => :descending}]
    end

    order
  end

  def per_page
    50
  end
end
