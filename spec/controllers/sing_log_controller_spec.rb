# _*_ coding: utf-8 _*_
require 'spec_helper'

describe SingLogController do
  fixtures :sing_logs

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
end
