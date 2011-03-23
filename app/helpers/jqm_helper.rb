# _*_ coding: utf-8 _*_
module JqmHelper
  def jqm_search_page
    output = <<-HTML
    <div data-role="page" data-theme="a" id="search">
      <div data-role="header">
         <a href="/" data-icon="home" data-transition="slide" data-direction="reverse">Home</a>
         <h1>曲検索</h1>
      </div>

      <div data-role="content" data-theme="a">
        <form action="#{url_for(:controller => 'pasokara', :action => 'solr_search', :query => nil, :page => nil)}" method="post">
          <div data-role="fieldcontain">
            <label for="query">検索:</label>
            <input type="search" name="query" id="search" value="" />
            <label for="field">検索対象:</label>
            #{select_tag("field", options_for_select([["全て", "a"], ["名前", "n"], ["タグ", "t"], ["説明", "d"], ["Raw", "r"]], params[:field]))}
            <input type="submit" data-theme="c" value="Search" />
          </div>
        </form>
        <ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b">
          <li data-role="list-divider">Topタグ一覧</li>
          HTML
          @header_tags.each do |tag|
            output += <<-HTML
            <li>#{h(tag.name)}<span class="ui-li-count ui-btn-up-c ui-btn-corner-all">#{tag.count.to_s}</span></li>
            HTML
          end
    output += <<-HTML
        </ul>
      </div>
    </div>
    HTML
    output
  end

  def jqm_login_page
    output = <<-HTML
    <div data-role="page" data-theme="a" id="login">
      <div data-role="header">
         <a href="/" data-icon="home" data-transition="slide" data-direction="reverse">Home</a>
         <h1>Login</h1>
      </div>

      <div data-role="content">
        <p>
        一度ログインすると、ページ下部の一覧に表示され、<br />
        ID入力せずに切り替えることが出来るようになります。
        </p>
        <form action="#{session_path}" method="post">
          <div data-role="fieldcontain">
            <p>#{label_tag 'ユーザーID'}<br />
            #{text_field_tag 'login', @login}</p>

            <p>#{label_tag 'パスワード'}<br/>
            #{password_field_tag 'password', nil}</p>

            <p>#{submit_tag 'ログインする'}</p>
          </div>
        </form>
        <ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b">
          <li data-role="list-divider">ログイン済みユーザー</li>
          <li>test</li>
        </ul>
      </div>
    </div>
    HTML
    output
  end

  def jqm_entity_li(entity)
    content_tag(:li, :class => entity.class.to_s.underscore) do
      send("jqm_" + entity.class.to_s.underscore + "_li", entity)
    end
  end

  def jqm_directory_li(directory)
    image_tag("icon/elastic_movie.png", :size => @icon_size, :class => "ui-li-icon") +
    link_to(h(directory.name), {:controller => "dir", :action => "show", :id => directory.id})
  end

  def jqm_pasokara_file_li(pasokara)
    image_tag("icon/music_48x48.png", :size => @icon_size, :class => "ui-li-icon") +
    link_to(h(" "), {:controller => "pasokara", :action => "show", :id => pasokara.id}) + 
    content_tag(:p, h(pasokara.name))
  end

  def jqm_info_list(entity)
    %Q{
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">ニコニコID:</span><span class="ui-block-b">#{link_to(entity.nico_name, entity.nico_url) if entity.nico_name}</span><br />
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">投稿日:</span><span class="ui-block-b">#{h entity.nico_post_str}</span><br />
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">再生数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_view_counter)}</span><br />
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">コメント数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_comment_num)}</span><br />
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">マイリスト数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_mylist_counter)}</span><br />
        </div>
      </li>
    }
  end
end
