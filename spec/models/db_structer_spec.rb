# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

describe Util::DbStructer do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_dir_attributes = {
      :name => "subdir",
      :directory_id => 8480,
    }

    @valid_pasokara_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :nico_name => "sm111111",
    }

    @valid_already_pasokara = {
      :name => "esp",
      :md5_hash => "927c1d8f95b97329f33f903f9e1f6fc5",
    }
  end

  it "create_directory(@valid_dir_attributes)でDirectoryレコードが作成されること" do
    dir_id = Util::DbStructer.new.create_directory(@valid_dir_attributes)
    created = Directory.find(dir_id)
    created.name.should == @valid_dir_attributes[:name]
    created.directory.should == Directory.find(8480)
  end

  it "create_pasokara_file(@valid_pasokara_attributes)でPasokaraFileレコードが作成されること" do
    pasokara_id = Util::DbStructer.new.create_pasokara_file(@valid_pasokara_attributes)
    created = PasokaraFile.find(pasokara_id)
    created.name.should == @valid_pasokara_attributes[:name]
    created.md5_hash.should == @valid_pasokara_attributes[:md5_hash]
    created.nico_name.should == @valid_pasokara_attributes[:nico_name]
  end

  it "create_pasokara_file(@valid_already_pasokara)で既存のPasokaraFileレコードが更新されること" do
    pasokara_id = Util::DbStructer.new.create_pasokara_file(@valid_already_pasokara)
    created = PasokaraFile.find(pasokara_id)
    created.name.should == @valid_already_pasokara[:name]
    created.md5_hash.should == @valid_already_pasokara[:md5_hash]
  end
end
