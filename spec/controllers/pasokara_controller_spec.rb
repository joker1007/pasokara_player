# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasokaraController do
  fixtures :directories, :pasokara_files, :computers

  #Delete this example and add some real ones
  it "should use PasokaraController" do
    controller.should be_an_instance_of(PasokaraController)
  end

  describe "GET '/pasokara/queue/8340'" do
    before do
      get 'queue', :id => "8340"
    end

    it "リクエストが成功しリダイレクトされること" do
      response.should be_redirect
    end

    it "COOL&CREATE - ESP RAGING [myu314 remix].aviのデータが読み込まれること" do
      assigns[:pasokara].name.should == "COOL&CREATE - ESP RAGING [myu314 remix].avi"
    end

    it "dir/indexにリダイレクトされること" do
      response.should redirect_to("/")
    end
  end
  
  describe "GET '/pasokara/queue/sm7601746'" do
    before do
      get 'queue', :id => "sm7601746"
    end

    it "リクエストが成功しリダイレクトされること" do
      response.should be_redirect
    end

    it "【ニコカラ】Just Be Friends halyosy ver. 歌入り(sm7601746).mp4のデータが読み込まれること" do
      assigns[:pasokara].name.should == "【ニコカラ】Just Be Friends halyosy ver. 歌入り(sm7601746).mp4"
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
      assigns[:pasokara].name.should == "COOL&CREATE - ESP RAGING [myu314 remix].avi"
    end

    it "pasokara/showテンプレートが表示されること" do
      response.should render_template("pasokara/show")
    end
  end
  
end
