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
    tag_str += content_tag("h3", "タグ")
    tag_str += tag_list(entity)
    content_tag("div", tag_str, {:id => "tag-box-#{entity.id}", :class => "tag_box"}) + "\n"
  end

  def tag_list(entity)
    tag_str = ""
    tag_idx = 1
    entity.tag_list.each do |p_tag|
      tag_str += content_tag("span",
        link_to(p_tag, tag_search_path(:tag => p_tag)),
      {:class => "tag"})
      tag_idx += 1
    end
    tag_str += link_to_remote("[編集]", :url => tag_form_open_path(:id => entity), :html => {:href => tag_form_open_path(:id => entity), :class => "tag_edit_link"})
    content_tag("div", tag_str, {:id => "tag-list-#{entity.id}", :class => "tag_list"})
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
    content_tag("div", content_tag("span",
      link_to(p_tag, tag_search_path(:tag => p_tag)) + " " +
      link_to_remote(image_tag("icon/tag_del_button.png"), {:url => tag_remove_path(:id => entity, :tag => p_tag, :tag_idx => tag_idx), :confirm => "#{p_tag}を削除してよろしいですか？"}, :href => tag_remove_path(:id => entity, :tag => p_tag)),
    {:class => "tag"}), {:id => "tag-#{entity.id}-#{tag_idx}"})
  end

  def search_form
    form_tag_str = form_tag :controller => 'pasokara', :action => 'search' do
      content_tag(:label, "曲名検索: ") +
      text_field_tag("query", "", :size => 32) +
      submit_tag("Search")
    end
    form_tag_str
  end

  def tag_search_form
    form_tag_str = form_tag :controller => 'pasokara', :action => 'tag_search' do
      content_tag(:label, "タグ検索: ") +
      text_field_tag("tag", "", :size => 32) +
      submit_tag("Search")
    end
    form_tag_str
  end

  def all_tag_list
    tag_str = ""
    PasokaraFile.tag_counts(:limit => 20, :order => 'count desc').each do |t|
      tag_str += content_tag("span",
        link_to(t.name, tag_search_path(:tag => t.name)) + "(#{t.count})",
      {:class=> "tag"})
    end
    content_tag("div", content_tag("h3", "タグ一覧") + tag_str, {:class => "all_tag_list"})
  end
end
