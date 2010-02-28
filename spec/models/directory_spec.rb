# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe Directory do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_attributes = {
      :name => "SOUND HOLIC",
      :fullpath => "L:\\pasokara\\SOUND HOLIC",
      :relative_path => "SOUND HOLIC",
    }

    @no_name_attributes = {
      :fullpath => "L:\\pasokara\\SOUND HOLIC",
      :relative_path => "SOUND HOLIC",
    }

    @no_fullpath_attributes = {
      :name => "SOUND HOLIC",
      :relative_path => "SOUND HOLIC",
    }

    @no_relative_path_attributes = {
      :name => "SOUND HOLIC",
      :fullpath => "L:\\pasokara\\SOUND HOLIC",
    }

    @cool_and_create = directories(:cool_and_create_dir)
  end

  it "適切なパラメーターで作成されること" do
    dir = Directory.new(@valid_attributes)
    dir.save!.should be_true
  end

  it "nameが無い場合DBエラーになること" do
    test_for_db_error do
      dir = Directory.new(@no_name_attributes)
      dir.save_with_validation(false)
    end
  end

  it "nameが無い場合バリデーションエラーになること" do
    dir = Directory.new(@no_name_attributes)
    dir.save.should be_false
    dir.should have(1).errors_on(:name)
  end

  it "fullpathが無い場合DBエラーになること" do
    test_for_db_error do
      dir = Directory.new(@no_fullpath_attributes)
      dir.save_with_validation(false)
    end
  end

  it "fullpathが無い場合バリデーションエラーになること" do
    dir = Directory.new(@no_fullpath_attributes)
    dir.save.should be_false
    dir.should have(1).errors_on(:fullpath)
  end

  it "relative_pathが無い場合DBエラーになること" do
    test_for_db_error do
      dir = Directory.new(@no_relative_path_attributes)
      dir.save_with_validation(false)
    end
  end

  it "relative_pathが無い場合バリデーションエラーになること" do
    dir = Directory.new(@no_relative_path_attributes)
    dir.save.should be_false
    dir.should have(1).errors_on(:relative_path)
  end

  it "entitiesメソッドで、下位ディレクトリ、ファイルのリストを返すこと" do
    @cool_and_create.should have(3).entities
  end

  it "コンピューターIDが異なるかつフルパスが同一のディレクトリが作成できること" do
    Directory.create!(@valid_attributes.merge :computer_id => 1)
    same_dir_dif_computer = Directory.new(@valid_attributes.merge :computer_id => 2)
    same_dir_dif_computer.save.should be_true
  end

  it "同じコンピューターIDかつフルパスが同一のディレクトリは作成できないこと(DBエラー)" do
    Directory.create(@valid_attributes.merge :computer_id => 1)
    test_for_db_error do
      same_dir_same_computer = Directory.new(@valid_attributes.merge :computer_id => 1)
      same_dir_same_computer.save_with_validation(false)
    end
  end

  it "同じコンピューターIDかつフルパスが同一のディレクトリは作成できないこと(バリデーションエラー)" do
    Directory.create(@valid_attributes.merge :computer_id => 1)
    same_dir_same_computer = Directory.new(@valid_attributes.merge :computer_id => 1)
    same_dir_same_computer.save.should be_false
    same_dir_same_computer.should have(1).errors_on(:fullpath)
  end
end
