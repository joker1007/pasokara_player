# _*_ coding: utf-8 _*_
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PasokaraHelper

  def header_loading
    stylesheet_link_tag('main') +
    stylesheet_link_tag('entity') +
    stylesheet_link_tag('header') +
    stylesheet_link_tag('scaffold') +
    stylesheet_link_tag('jquery.fancybox') +
    javascript_include_tag(:defaults) +
    javascript_include_tag("jquery-1.3.2.min.js") +
    javascript_include_tag("jquery-fonteffect-1.0.0.min.js") +
    javascript_include_tag("jquery.linkwrapper-1.0.3.js") +
    javascript_include_tag("jquery.lazyload.mini.js")
  end

  def navi_bar
    str = %Q{
      <ul id="menu">
        <li>#{link_to("ホーム", {:controller => 'dir', :action => 'index'}, :id => "home")}</li>
        <li>#{link_to("予約確認", {:controller => 'queue', :action => 'list'}, :id => "queue")}</li>
        <li>#{link_to("りれき", {:controller => 'sing_log', :action => 'list'}, :id => "history")}</li>
    }
    if current_user
      str += %Q{
        <li>#{link_to("お気に入り", {:controller => 'favorite', :action => 'list'}, :id => "favorite")}</li>
        <li>#{link_to("設定変更", edit_user_path(current_user.id), :id => "user_edit")}</li>
      }
    end
    str += %Q{
        <li>#{link_to("使い方", {:controller => 'help', :action => 'usage'}, :id => "usage")}</li>
      </ul>
    }
    str
  end


  def search_form
    form_tag(:controller => 'pasokara', :action => 'search', :query => nil, :page => nil) + "\n" +
    content_tag(:label, "曲名・タグ検索: ") +
    text_field_tag("query", params[:query], :size => 32) +
    submit_tag("Search") + "\n" +
    "</form>" + "\n" +
    "半角スペースでAND検索"
  end

  def solr_search_form
    "<div id=\"solr_search\" class=\"search\">" +
    form_tag(:controller => 'pasokara', :action => 'solr_search', :query => nil, :page => nil) + "\n" +
    content_tag(:label, "Solr検索: ") +
    text_field_tag("query", params[:query], :size => 56) + " : " +
    select_tag("field", options_for_select([["全て", "a"], ["名前", "n"], ["タグ", "t"], ["説明", "d"], ["Raw", "r"]], params[:field])) +
    submit_tag("Search") + "\n" +
    "</form>" +
    "</div>"
  end


  def tag_search_form
    form_tag(:controller => 'pasokara', :action => 'tag_search', :tag => nil, :page => nil) + "\n" +
    content_tag(:label, "タグ検索: ") +
    text_field_tag("tag", "", :size => 32) +
    submit_tag("Search") + "\n" +
    "</form>"
  end

  def scoped_tags(tags)
    form_tag(:action => "append_search_tag") +
    content_tag(:label, "タグスコープ:") +
    tags.inject("") do |str, t|
      remove_scope = link_to(image_tag("icon/cancel_16.png"), {:remove => t}, :class => "remove_scope")
      str += content_tag(:span, h(t) + remove_scope, :class => "scoped_tag") + " > "
      str
    end +
    hidden_field_tag("tag", params[:tag]) +
    text_field_tag("append", "", :size => 16) +
    submit_tag("タグ追加") +
    "</form>"
  end

  def header_tag_list(tags, query = nil)
    content_tag(:div, :class => "all_tag_list", :id => "all_tag_list") do 
      content_tag("h3", "タグ一覧", :style => "display: inline; margin-right: 10px;") +
      link_to("[全てのタグ一覧]", {:controller => "tag", :action => "list"}, :class => "tag_list_link") + "<br />\n" +
      tags.inject("") do |str, t|
        str += content_tag(:span, :class => "tag") do
          link_to(h(t.name), t.link_options) + "(#{t.count})"
        end + "\n"
        str
      end
    end
  end

  def embed_player(pasokara)
    "<embed id='player' name='player' src='/swfplayer/player-viral.swf' height='360' width='480' allowscriptaccess='always' allowfullscreen='true' flashvars='file=#{u pasokara.movie_path}&level=0&skin=%2Fswfplayer%2Fsnel.swf&image=#{u(url_for(:controller => "pasokara", :action => "thumb", :id => pasokara.id) + ".jpg")}&title=#{u pasokara.name}&autostart=true&dock=false&bandwidth=5000&plugins=viral-2d'/>"
  end

  def embed_player_iphone(pasokara)
    %Q{
      <video id="video_#{pasokara.id}" controls>
        <source src="#{pasokara.movie_path}" type="video/mp4">
      </video>
    }
  end
end
