# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasokaraController do
  fixtures :directories, :pasokara_files, :computers, :tags, :taggings, :users

  before do
    @esp_raging = pasokara_files(:esp_raging)
    @just_be_friends = pasokara_files(:just_be_friends)
  end

  #Delete this example and add some real ones
  it "should use PasokaraController" do
    controller.should be_an_instance_of(PasokaraController)
  end

  describe "GET '/pasokara/queue/8340'" do
    before do
      PasokaraFile.should_receive(:find).with("8340").and_return(@esp_raging)
      get 'queue', :id => "8340"
    end

    it "リクエストが成功しリダイレクトされること" do
      response.should be_redirect
    end

    it "COOL&CREATE - ESP RAGING [myu314 remix].aviのデータが読み込まれること" do
      assigns[:pasokara].id.should == 8340
    end

    it "dir/indexにリダイレクトされること" do
      response.should redirect_to("/")
    end
  end
  
  describe "GET '/pasokara/queue/8340' user_id = 1" do
    before do
      session[:current_user] = 1
      QueuedFile.should_receive(:enq).with(@esp_raging, 1)
      get 'queue', :id => "8340"
    end

    it "リクエストが成功しリダイレクトされること" do
      response.should be_redirect
    end

    it "COOL&CREATE - ESP RAGING [myu314 remix].aviのデータが読み込まれること" do
      assigns[:pasokara].id.should == 8340
    end

    it "dir/indexにリダイレクトされること" do
      response.should redirect_to("/")
    end
  end
  
  describe "GET '/pasokara/queue/sm7601746'" do
    before do
      PasokaraFile.should_receive(:find_by_nico_name).with("sm7601746").and_return(@just_be_friends)
      get 'queue', :id => "sm7601746"
    end

    it "リクエストが成功しリダイレクトされること" do
      response.should be_redirect
    end

    it "【ニコカラ】Just Be Friends halyosy ver. 歌入り(sm7601746).mp4のデータが読み込まれること" do
      assigns[:pasokara].id.should == 9118
    end

    it "dir/indexにリダイレクトされること" do
      response.should redirect_to("/")
    end
  end

  describe "GET '/pasokara/queue/abcd'" do
    before do
      get 'queue', :id => "abcd"
    end

    it "リクエストが失敗すること" do
      response.code.should == "404"
    end

    it "エラーメッセージが表示されること" do
      response.body == "パラメーターが不正です"
    end
  end

  describe "GET '/pasokara/show/8340'" do
    before do
      get 'show', :id => "8340"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "COOL&CREATE - ESP RAGING [myu314 remix].aviのデータが読み込まれること" do
      assigns[:pasokara].id.should == 8340
    end

    it "pasokara/showテンプレートが表示されること" do
      response.should render_template("pasokara/show")
    end
  end
  
  describe "GET '/pasokara/search/ニコカラ'" do
    before do
      get 'search', :query => "ニコカラ"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "ファイル名順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8340
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end
  
  describe "GET '/pasokara/search/ニコカラ?sort=view_count'" do
    before do
      get 'search', :query => "ニコカラ", :sort => "view_count"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "再生回数が多い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8362
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 9118
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/search/ニコカラ?sort=view_count_r'" do
    before do
      get 'search', :query => "ニコカラ", :sort => "view_count_r"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "再生回数が少ない順に並んでいること" do
      assigns[:pasokaras][0].id.should == 9118
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/search/ニコカラ?sort=post_new'" do
    before do
      get 'search', :query => "ニコカラ", :sort => "post_new"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "投稿日時が新しい順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8340
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/search/ニコカラ?sort=post_old'" do
    before do
      get 'search', :query => "ニコカラ", :sort => "post_old"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "投稿日時が古い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8362
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8340
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/search/ニコカラ?sort=mylist_count'" do
    before do
      get 'search', :query => "ニコカラ", :sort => "mylist_count"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "マイリストが多い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 9118
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ'" do
    before do
      get 'tag_search', :tag => "ニコカラ"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "ファイル名順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8340
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ?sort=view_count'" do
    before do
      get 'tag_search', :tag => "ニコカラ", :sort => "view_count"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "再生回数の多い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8362
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 9118
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ?sort=view_count_r'" do
    before do
      get 'tag_search', :tag => "ニコカラ", :sort => "view_count_r"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "再生回数の少ない順に並んでいること" do
      assigns[:pasokaras][0].id.should == 9118
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ?sort=post_new'" do
    before do
      get 'tag_search', :tag => "ニコカラ", :sort => "post_new"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "投稿日時の新しい順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8340
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ?sort=post_old'" do
    before do
      get 'tag_search', :tag => "ニコカラ", :sort => "post_old"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "投稿日時の古い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 8362
      assigns[:pasokaras][1].id.should == 9118
      assigns[:pasokaras][2].id.should == 8340
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end

  describe "GET '/pasokara/tag_search/ニコカラ?sort=mylist_count'" do
    before do
      get 'tag_search', :tag => "ニコカラ", :sort => "mylist_count"
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "3件のデータが読み込まれること" do
      assigns[:pasokaras].length.should == 3
    end

    it "マイリストの多い順に並んでいること" do
      assigns[:pasokaras][0].id.should == 9118
      assigns[:pasokaras][1].id.should == 8340
      assigns[:pasokaras][2].id.should == 8362
    end

    it "pasokara/searchテンプレートが表示されること" do
      response.should render_template("pasokara/search")
    end
  end
end
