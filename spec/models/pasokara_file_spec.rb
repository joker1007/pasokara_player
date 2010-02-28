# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe PasokaraFile do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :fullpath => "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :relative_path => "COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @no_name_attributes = {
      :fullpath => "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :relative_path => "COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @no_fullpath_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :relative_path => "COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @no_relative_path_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :fullpath => "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @no_md5_hash__attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :fullpath => "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
      :relative_path => "COOL&CREATE\\COOL&CREATE - ネココタマツリ.avi",
    }

    @cool_and_create = directories(:cool_and_create_dir)
    @esp_raging = pasokara_files(:esp_raging)
    @siawase_gyaku = pasokara_files(:siawase_gyaku)
  end

  it "適切なパラメーターで作成されること" do
    PasokaraFile.create!(@valid_attributes)
  end

  it "nameが無い場合DBエラーになること" do
    test_for_db_error do
      pasokara = PasokaraFile.new(@no_name_attributes)
      pasokara.save_with_validation(false)
    end
  end

  it "fullpathが無い場合DBエラーになること" do
    test_for_db_error do
      pasokara = PasokaraFile.new(@no_fullpath_attributes)
      pasokara.save_with_validation(false)
    end
  end

  it "relative_pathが無い場合DBエラーになること" do
    test_for_db_error do
      pasokara = PasokaraFile.new(@no_relative_path_attributes)
      pasokara.save_with_validation(false)
    end
  end

  it "md5_hashが無い場合エラーになること" do
    test_for_db_error do
      pasokara = PasokaraFile.new(@no_md5_hash_attributes)
      pasokara.save_with_validation(false)
    end
  end

  it "ディレクトリに含まれることができる" do
    pasokara = @cool_and_create.pasokara_files.create!(@valid_attributes)
    pasokara.directory.should == @cool_and_create
    @cool_and_create.pasokara_files.should have(3).items
  end

  it "コンピューターIDが異なるかつフルパスが同一のファイルが作成できること" do
    PasokaraFile.create!(@valid_attributes.merge :computer_id => 1)
    same_pasokara_dif_computer = PasokaraFile.new(@valid_attributes.merge :computer_id => 2)
    same_pasokara_dif_computer.save.should be true
  end

  it "同じコンピューターIDかつフルパスが同一のファイルが作成できないこと(DBエラー)" do
    PasokaraFile.create!(@valid_attributes.merge :computer_id => 1)
    test_for_db_error do
      same_pasokara_same_computer = PasokaraFile.new(@valid_attributes.merge :computer_id => 1)
      same_pasokara_same_computer.save_with_validation(false)
    end
  end

  it "同じコンピューターIDかつフルパスが同一のファイルが作成できないこと(バリデーションエラー)" do
    PasokaraFile.create!(@valid_attributes.merge :computer_id => 1)
    same_pasokara_same_computer = PasokaraFile.new(@valid_attributes.merge :computer_id => 1)
    same_pasokara_same_computer.save.should be_false
    same_pasokara_same_computer.should have(1).errors_on(:fullpath)
    same_pasokara_same_computer.should have(1).errors_on(:md5_hash)
  end

end
