# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HelpController do
  describe "GET 'usage'" do
    before do
      get 'usage'
    end

    it "リクエストが成功すること" do
      response.should be_success
    end

    it "help/usageを描画すること" do
      response.should render_template("help/usage")
    end
  end
end
