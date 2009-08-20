# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def entity_li(entities)
    tag_str = ""
    entities.each do |entity|
      if entity.class == Directory and !entity.entities.empty?
        tag_str += "<li class=\"dir\">#{image_tag("icon/elastic_movie.png", :size => "24x24", :class=> "entity_icon")}#{link_to(h(entity.name), :action => 'show', :id => entity)}</li>\n"
      elsif entity.class == PasokaraFile
        tag_str += "<li class=\"pasokara\">#{image_tag("icon/music_48x48.png", :size => "24x24", :class=> "entity_icon")}#{link_to(h(entity.name), :controller => 'pasokara', :action => 'queue', :id => entity)}</li>\n"
        tag_str += tag_box(entity)
      end
    end
    tag_str
  end

  def tag_box(entity)
    tag_str = ""
    tag_str += javascript_tag("function tag_list_#{entity.id}(){" + update_page {|page| page.replace "tag-list-#{entity.id}", tag_list(entity)} + "}")
    tag_str += javascript_tag("function tag_list_edit_#{entity.id}(){" + update_page {|page| page.replace "tag-list-#{entity.id}", tag_list_edit(entity)} + "}")
    tag_str += content_tag("h3", "タグ")
    tag_str += tag_list(entity)
    content_tag("div", tag_str, {:id => "tag-box-#{entity.id}", :class => "tag_box"}) + "\n"
  end

  def tag_list(entity)
    tag_str = ""
    tag_idx = 1
    entity.tag_list.each do |p_tag|
      tag_str += content_tag("span",
        link_to(p_tag, {:controller => 'pasokara', :action => 'tag_search', :tag => p_tag}),
      {:class => "tag"})
      tag_idx += 1
    end
    tag_str += link_to_function("[編集]", "tag_list_edit_#{entity.id}()", :class => "tag_edit_link")
    content_tag("div", tag_str, {:id => "tag-list-#{entity.id}", :class => "tag_list"})
  end

  def tag_list_edit(entity)
    tag_str = ""
    tag_idx = 1
    entity.tag_list.each do |p_tag|
      tag_str += content_tag("div", content_tag("span",
        link_to(p_tag, {:controller => 'pasokara', :action => 'tag_search', :tag => p_tag}) + " " +
        link_to_remote(image_tag("icon/tag_del_button.png"), {:url => {:controller => 'pasokara', :action => 'remove_tag', :id => entity, :tag => p_tag, :tag_idx => tag_idx}, :confirm => "#{p_tag}を削除してよろしいですか？"}, :href => url_for(:controller => 'pasokara', :action => 'remove_tag', :id => entity, :tag => p_tag)),
      {:class => "tag"}), {:id => "tag-#{entity.id}-#{tag_idx}"})
      tag_idx += 1
    end
    tag_str += "<form action=\"#{url_for :controller => 'pasokara', :action => 'tagging', :id => entity}\" method=\"post\"><input type=\"hidden\" name=\"authenticity_token\" value=\"#{form_authenticity_token}\"><input type=\"text\" name=\"tags\" size=\"50\" /><input type=\"submit\" value=\"編集\" />" + link_to_function("[完了]", "tag_list_#{entity.id}()", :class => "tag_edit_link") + "</form>"
    content_tag("div", tag_str, {:id => "tag-list-#{entity.id}", :class => "tag_list_edit"})
  end

  def search_form
    content_tag(:label, "曲名検索: ") +
    text_field_tag("query", "", :size => 32) +
    submit_tag("Search")
  end

  def tag_search_form
    content_tag(:label, "タグ検索: ") +
    text_field_tag("tag", "", :size => 32) +
    submit_tag("Search")
  end

  def all_tag_list
    tag_str = ""
    PasokaraFile.tag_counts.each do |t|
      tag_str += content_tag("span",
        link_to(t.name, :controller => 'pasokara', :action => 'tag_search', :tag => t.name) + "(#{t.count})",
      {:class=> "tag"})
    end
    content_tag("div", content_tag("h3", "タグ一覧") + tag_str, {:class => "all_tag_list"})
  end
end
