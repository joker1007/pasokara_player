require 'spec_helper'

describe QueueController do
  fixtures :pasokara_files, :sing_logs

  before do
    @esp_raging = pasokara_files(:esp_raging)
  end

  #Delete this example and add some real ones
  it "should use QueueController" do
    controller.should be_an_instance_of(QueueController)
  end

  describe "GET deque" do
    describe "queueがある場合" do

      before do
        QueuedFile.enq @esp_raging
      end

      it "成功のレスポンスを返す" do
        get 'deque'
        response.should be_success
      end

      it "QueuedFile.deqメソッドが呼ばれること" do
        QueuedFile.should_receive(:deq).once.and_return(@esp_raging)
        get 'deque'
      end

      it "GET deque.xmlでxmlレスポンスを返すこと" do
        get 'deque', :format => "xml"
        response.body.should == @esp_raging.to_xml
      end

      it "キューのレコード数が1減少すること" do
        QueuedFile.find(:all).size.should == 1
        get 'deque', :format => "xml"
        QueuedFile.find(:all).size.should == 0
      end

      it "SingLogのレコード数が1増加すること" do
        SingLog.find(:all).size.should == 2
        get 'deque', :format => "xml"
        SingLog.find(:all).size.should == 3
      end
    end

    describe "queueがない場合" do

      it "404のレスポンスを返す" do
        get 'deque'
        response.status.to_i.should == 404
      end
    end
  end

  describe "GET list" do
    before do
      QueuedFile.enq @esp_raging
      QueuedFile.enq @esp_raging
    end

    it "成功のレスポンスを返す" do
      response.should be_success
    end

    it "キューに並んでいるレコードが読みこまれること" do
      get 'list'
      assigns[:queue_list].size.should == 2
    end

    it "QueuedFile.findメソッドが呼ばれること" do
      QueuedFile.should_receive(:find).with(:all, :order => "created_at", :include => :pasokara_file)
      get 'list'
    end
  end

end
