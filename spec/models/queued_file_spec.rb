# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe QueuedFile do
  before(:each) do
    @valid_attributes = {
      :pasokara_file_id => 8340,
    }

    @no_file_attributes = {
      :pasokara_file_id => 1111,
    }
  end

  it "適切なパラメーターで作成されること" do
    QueuedFile.create!(@valid_attributes)
  end

  it "存在しないファイルIDをキューに入れようとするとエラーになること" do
    test_for_db_error do
      QueuedFile.create!(@no_file_attributes)
    end
  end
end
