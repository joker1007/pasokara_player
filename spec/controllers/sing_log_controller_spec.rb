# _*_ coding: utf-8 _*_
require 'spec_helper'

describe SingLogController do
  fixtures :sing_logs

  #Delete these examples and add some real ones
  it "should use SingLogController" do
    controller.should be_an_instance_of(SingLogController)
  end


  describe "GET 'list'" do
    it "should be successful" do
      get 'list'
      response.should be_success
    end

    it "50個までのSingLogデータがロードされること" do
      get 'list'
      assigns[:sing_logs].should == SingLog.paginate(:all, :order => "created_at desc", :per_page => 50, :page => 1, :include => :pasokara_file)
    end
  end

  describe "GET 'show/1'" do
    it "should be successful" do
      get 'show', :id => 1
      response.should be_success
    end

    it "idが1のSingLogデータがロードされること" do
      get 'show', :id => 1
      assigns[:sing_log].should == SingLog.find(1)
    end
  end
end
