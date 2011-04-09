# _*_ coding: utf-8 _*_
module JqmHelper
  def jqm_nav_bar
    login_menu = ""
    if current_user
      login_menu += "<li>#{link_to("お気に入り", {:controller => "favorite", :action => "list"})}</li>\n"
      login_menu += "<li>#{link_to("設定", edit_user_path(current_user))}</li>\n"
    end

    output = <<-HTML
      <div data-role="navbar">
        <ul>
          <li>#{link_to("ホーム", root_path)}</li>
          <li>#{link_to("予約確認", {:controller => "queue", :action => "list"})}</li>
          #{login_menu}
        </ul>
      </div>
    HTML
    output
  end

  def jqm_search_form
    output = <<-HTML
      <form action="#{url_for(:controller => 'pasokara', :action => 'solr_search', :query => nil, :page => nil)}" method="post">
        <div data-role="fieldcontain">
          <label for="query">検索:</label>
          <input data-theme="c" type="search" name="query" id="search" placeholder="Search" />
          <label for="field">検索対象:</label>
          #{select_tag("field", options_for_select([["全て", "a"], ["名前", "n"], ["タグ", "t"], ["説明", "d"], ["Raw", "r"]], params[:field]))}
          <input type="submit" data-theme="c" value="Search" />
        </div>
      </form>
    HTML
  end

  def jqm_header_tag(title = "Topタグ一覧")
    list_html = @header_tags.inject("") do |html, t|
      html += "<li>#{link_to(h(t.name), t.link_options)}<span class=\"ui-li-count ui-btn-up-c ui-btn-corner-all\">#{t.count.to_s}</span></li>\n"
    end
    output = <<-HTML
      <div data-role="collapsible" data-collapsed="true" data-theme="a">
        <h3>#{title}</h3>
        <ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="b">
          #{list_html}
        </ul>
      </div>
    HTML
  end

  def jqm_search_page(custom_options = {})
    default_options = {:role => "page", :html_id => "search", :theme => "a"}
    options = default_options.merge(custom_options)
    output = <<-HTML
    <div data-role="#{options[:role]}" data-theme="#{options[:theme]}" id="#{options[:html_id]}">
      <div data-role="header">
        <a href="#" data-rel="back" data-icon="back">Back</a>
        <h1>曲検索</h1>
        <a href="/" data-icon="home" data-transition="slide" data-direction="reverse">Home</a>
      </div>

      <div data-role="content">
        #{jqm_search_form}
      </div>
    </div>
    HTML
    output
  end

  def jqm_login_button
    if current_user
      link_to(current_user.name, "#login", "data-transition".to_sym => "slidedown", "data-theme".to_sym => "c")
    else
      link_to("Login", "#login", "data-transition".to_sym => "slidedown")
    end
  end

  def jqm_login_page
    users = User.find(session[:logined_users]) if session[:logined_users]
    logined_users = users ? users.inject("") do |html, user|
      html += "<li>#{link_to(user.name, switch_user_path(:id => user))}</li>"
    end : "<li>No User</li>"
    output = <<-HTML
    <div data-role="page" data-theme="a" id="login">
      <div data-role="header">
        <a href="#" data-rel="back" data-icon="back">Back</a>
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
          #{logined_users}
        </ul>

        #{jqm_logout_all}
      </div>
    </div>
    HTML
    output
  end

  def jqm_logout_all
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

  def jqm_queued_file_li(queue)
    image_tag("icon/music_48x48.png", :size => @icon_size, :class => "ui-li-icon") +
    link_to(h(" "), {:controller => "pasokara", :action => "show", :id => queue.pasokara_file.id}) +
    content_tag(:p, h(queue.pasokara_file.name)) +
    link_to(h("取消"), {:controller => "queue", :action => "confirm_remove", :id => queue.id}, "data-rel".to_sym => "dialog", "data-transition".to_sym => "pop")
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
          <span class="ui-block-a">投稿日:</span><span class="ui-block-b">#{h entity.nico_post_str}</span>
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">再生数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_view_counter)}</span>
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">コメント数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_comment_num)}</span>
        </div>
      </li>
      <li>
        <div class="ui-grid-a">
          <span class="ui-block-a">マイリスト数:</span><span class="ui-block-b">#{number_with_delimiter(entity.nico_mylist_counter)}</span>
        </div>
      </li>
    }
  end
end
