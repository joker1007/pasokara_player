# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DirController do
  fixtures :directories, :pasokara_files, :computers

  #Delete these examples and add some real ones
  it "should use DirController" do
    controller.should be_an_instance_of(DirController)
  end


  describe "GET 'index'" do
    before do
      get 'index'
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "トップレベルのディレクトリをすべてロードしていること" do
      assigns[:top_dirs].length.should == 2
    end

    it "dir/indexを描画すること" do
      response.should render_template("dir/index")
    end
  end

  describe "GET 'show'" do
    before do
      get 'show', :id => directories(:cool_and_create_dir).id
    end

    it "should be successful" do
      response.should be_success
    end

    it "指定したIDのディレクトリがロードされていること" do
      assigns[:dir].should == directories(:cool_and_create_dir)
    end

    it "dir/showを描画すること" do
      response.should render_template("dir/show")
    end
  end
end
