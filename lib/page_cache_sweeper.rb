class PageCacheSweeper < ActionController::Caching::Sweeper
  observe :directory, :pasokara_file

  def after_save(record)
    unless record.directory_id
      expire_page(:controller => "dir", :action => "index")
    else
      expire_page(:controller => "dir", :action => "show", :id => record.directory_id)
      #expire_page(:controller => "pasokara", :action => ["search", "tag_search"])
      expire_page("/search/*")
      expire_page("/tag_search/*")
    end
  end

end
