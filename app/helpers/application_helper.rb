# _*_ coding: utf-8 _*_
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def entity_li(entity)
    send(entity.class.to_s.underscore + "_li", entity)
  end

  def directory_li(directory)
    content_tag(:li, :class=> "dir") do
      image_tag("icon/elastic_movie.png", :size => @icon_size, :class => "entity_icon") +
      link_to(h(directory.name), {:controller => "dir", :action => "show", :id => directory.id})
    end
  end

  def pasokara_file_li(pasokara)
    content_tag(:li, :class=> "dir") do
      image_tag("icon/music_48x48.png", :size => @icon_size, :class => "entity_icon") +
      link_to(h(pasokara.name), {:controller => 'pasokara', :action => 'queue', :id => pasokara.id}) +
      link_to_remote("[詳細]", :url => {:controller => "pasokara", :action => "show", :id => pasokara.id}, :html => {:href => url_for(:controller => "pasokara", :action => "show", :id => pasokara.id), :class => "show_info", :id => "show-info-#{pasokara.id}"}) +
      link_to("[プレビュー]", pasokara.preview_path, :class => "preview_link", :target => "_blank") +
      link_to_remote(image_tag("icon/star_off_48.png", :size => @icon_size), :confirm => "#{pasokara.name}をお気に入りに追加しますか？", :url => {:controller => "favorite", :action => "add", :id => pasokara.id}, :html => {:href => url_for(:controller => "favorite", :action => "add", :id => pasokara.id), :class => "add_favorite"})
    end
  end

  def tag_li(tag_obj)
    content_tag(:li, :class=> "dir") do
      image_tag("icon/search.png", :size => @icon_size, :class => "tag_icon") +
      link_to(h(tag_obj.name), {:controller => "pasokara", :action => "tag_search", :tag => tag_obj.name}) +
      "(#{tag_obj.count})"
    end
  end

  def info_box(entity)
    %Q{
      <div id="info-box-#{entity.id}" class="info_box">
        <h3>タグ</h3>
        #{tag_list(entity)}
        #{info_list(entity)}
      </div>
    }
  end

  def info_list(entity)
    %Q{
      <div id="info-list-#{entity.id}" class="info_list">
        <h3>動画情報</h3>
        <div class="thumb clearfix">#{image_tag(url_for(:controller => "pasokara", :action => "thumb", :id => entity.id), :size => "160x120")}</div>
        <div class="nico_info clearfix">
          <span class="info_key">ニコニコID:</span><span class="info_value">#{link_to(entity.nico_name, "http://www.nicovideo.jp/watch/" + entity.nico_name) if entity.nico_name}</span><br />
          <span class="info_key">投稿日時:</span><span class="info_value">#{h entity.nico_post.strftime("%Y/%m/%d")}</span><br />
          <span class="info_key">再生数:</span><span class="info_value">#{number_with_delimiter(entity.nico_view_counter)}</span><br />
          <span class="info_key">コメント数:</span><span class="info_value">#{number_with_delimiter(entity.nico_comment_num)}</span><br />
          <span class="info_key">マイリスト数:</span><span class="info_value">#{number_with_delimiter(entity.nico_mylist_counter)}</span><br />
        </div>
      </div>
    }
  end

  def tag_box(entity)
    %Q{
      <div id="tag-box-#{entity.id}" class="tag_box">
        <h3>タグ</h3>
        #{tag_list(entity)}
      </div>
    }
  end

  def tag_list(entity)
    content_tag("div", {:id => "tag-list-#{entity.id}", :class => "tag_list"}) do
      entity.tag_list.inject("") do |str, p_tag|
        str << content_tag("span", {:class => "tag"}) do
          "<a href=\"/tag_search/#{u p_tag}\">#{h p_tag}</a>"
        end
        str
      end +
      link_to_remote("[編集]", :url => tag_form_open_path(:id => entity), :html => {:href => tag_form_open_path(:id => entity), :class => "tag_edit_link"})
    end
  end

  def tag_list_edit(entity)
    tag_str = ""
    tag_idx = 1
    entity.tag_list.each do |p_tag|
      tag_str += tag_line_edit(entity, p_tag, tag_idx)
      tag_idx += 1
    end
    content_tag("div",
      content_tag("div", tag_str, {:id => "tag-line-box-#{entity.id}"}) +
      tag_edit_form(entity),
    {:id => "tag-list-#{entity.id}", :class => "tag_list_edit"})
  end

  def tag_edit_form(entity)
    tag_str = form_remote_tag :url => tagging_path(:id => entity.id) do
      text_field_tag("tags", "", :size => 50) +
      submit_tag("編集") + " " +
      link_to_remote("[完了]", :url => tag_form_close_path(:id => entity), :html => {:href => tag_form_close_path(:id => entity), :class => "tag_edit_link"})
    end
    tag_str.join("\n")
  end

  def tag_line_edit(entity, p_tag, tag_idx)
    content_tag("div", {:id => "tag-#{entity.id}-#{tag_idx}"}) do
      content_tag("span", {:class => "tag"}) do
        link_to(h(p_tag), tag_search_path(:tag => p_tag)) + " " +
        link_to_remote(image_tag("icon/tag_del_button.png"), {:url => tag_remove_path(:id => entity, :tag => p_tag, :tag_idx => tag_idx), :confirm => "#{p_tag}を削除してよろしいですか？"}, :href => tag_remove_path(:id => entity, :tag => p_tag))
      end
    end
  end

  def search_form
    form_tag(:controller => 'pasokara', :action => 'search', :query => nil, :page => nil) + "\n" +
    content_tag(:label, "曲名・タグ検索: ") +
    text_field_tag("query", params[:query], :size => 32) +
    submit_tag("Search") + "\n" +
    "</form>" + "\n" +
    "半角スペースでAND検索"
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

  def header_tag_list(tags, url_builder)
    content_tag(:div, :class => "all_tag_list", :id => "all_tag_list") do 
      content_tag("h3", "タグ一覧", :style => "display: inline; margin-right: 10px;") +
      link_to("[タグ一覧]", {:controller => "tag", :action => "list"}, :class => "tag_list_link") + "<br />\n" +
      tags.inject("") do |str, t|
        str += content_tag(:span, :class => "tag") do
          "<a href=\"#{url_builder.call(t)}\">#{h(t.name)}</a>" + "(#{t.count})"
        end + "\n"
        str
      end
    end
  end

  def embed_player(pasokara)
    "<embed id='player' name='player' src='/swfplayer/player-viral.swf' height='360' width='480' allowscriptaccess='always' allowfullscreen='true' flashvars='file=#{u pasokara.movie_path}&level=0&skin=%2Fswfplayer%2Fsnel.swf&image=#{u(url_for(:controller => "pasokara", :action => "thumb", :id => pasokara.id) + ".jpg")}&title=#{u pasokara.name}&autostart=true&dock=false&bandwidth=5000&plugins=viral-2d'/>"
  end
end
