# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe QueuedFile do
  fixtures :pasokara_files, :computers

  before(:each) do
    @valid_attributes = {
      :pasokara_file_id => 8340,
    }

    @no_file_attributes = {
      :pasokara_file_id => 1111,
    }

    @just_be_friends = pasokara_files(:just_be_friends)
  end

  it "適切なパラメーターで作成されること" do
    QueuedFile.create!(@valid_attributes)
  end

  it "PasokaraFileをキューに入れられること" do
    QueuedFile.enq(@just_be_friends)
    QueuedFile.deq.pasokara_file.should == @just_be_friends
  end

  it "存在しないファイルIDをキューに入れようとするとエラーになること" do
    test_for_db_error do
      QueuedFile.create!(@no_file_attributes)
    end
  end
  
  it "dequeueされたときに、その曲の再生ログレコードが作成されること" do
    QueuedFile.enq @just_be_friends
    pasokara = QueuedFile.deq.pasokara_file
    SingLog.find(:last).pasokara_file.should == pasokara
  end
end
