# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def entity_li(entities)
    tag_str = ""
    entities.each do |entity|
      if entity.class == Directory and !entity.entities.empty?
        tag_str += "<li class=\"dir\">#{image_tag("icon/elastic_movie.png", :size => "24x24", :class=> "entity_icon")}#{link_to(h(entity.name), :action => 'show', :id => entity)}</li>\n"
      elsif entity.class == PasokaraFile
        tag_str += "<li class=\"pasokara\">#{image_tag("icon/music_48x48.png", :size => "24x24", :class=> "entity_icon")}#{link_to(h(entity.name), :controller => 'pasokara', :action => 'queue', :id => entity)}</li>\n"
      end
    end
    tag_str
  end

  def search_form
    content_tag(:label, "曲検索: ") +
    text_field_tag("query", "", :size => 32) +
    submit_tag("Search")
  end
end
