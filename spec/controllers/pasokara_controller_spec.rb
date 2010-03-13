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

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "COOL&CREATE - ESP RAGING [myu314 remix].aviのデータが読み込まれること" do
      assigns[:pasokara].name.should == "COOL&CREATE - ESP RAGING [myu314 remix].avi"
    end

    it "dir/indexにリダイレクトされること" do
      response.should render_template("dir/index")
    end
  end
end
