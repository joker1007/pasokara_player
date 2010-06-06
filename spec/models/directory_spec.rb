# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe Directory do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_attributes = {
      :name => "SOUND HOLIC",
    }

    @no_name_attributes = {
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

  it "entitiesメソッドで、下位ディレクトリ、ファイルのリストを返すこと" do
    @cool_and_create.should have(3).entities
  end

end
