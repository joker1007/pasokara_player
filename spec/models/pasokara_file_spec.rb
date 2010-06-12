# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe PasokaraFile do
  fixtures :directories, :pasokara_files, :computers, :taggings, :tags

  before(:each) do
    @valid_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }

    @duration_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :duration => 245,
    }

    @no_name_attributes = {
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
    }


    @no_md5_hash__attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
    }

    @cool_and_create = directories(:cool_and_create_dir)
    @esp_raging = pasokara_files(:esp_raging)
    @siawase_gyaku = pasokara_files(:siawase_gyaku)
    @just_be_friends = pasokara_files(:just_be_friends)
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

  it "md5_hashが無い場合エラーになること" do
    test_for_db_error do
      pasokara = PasokaraFile.new(@no_md5_hash_attributes)
      pasokara.save_with_validation(false)
    end
  end

  it "ディレクトリに含まれることができる" do
    @cool_and_create.should have(2).pasokara_files
    pasokara = @cool_and_create.pasokara_files.create!(@valid_attributes)
    pasokara.directory.should == @cool_and_create
    @cool_and_create.should have(3).pasokara_files
  end

  it "name(), name(true)がUTF-8を返すこと" do
    @siawase_gyaku.name.should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
    @siawase_gyaku.name(true).should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
  end

  it "name(false)がCP932を返すこと" do
    @siawase_gyaku.name(false).should == NKF.nkf("-W -s --cp932", "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv")
  end

  it "movie_pathが適切なファイルパスを返すこと" do
    @esp_raging.movie_path.should == "/pasokara/movie/8340.avi"
    @siawase_gyaku.movie_path.should == "/pasokara/movie/8362.flv"
  end

  it "preview_pathが適切なファイルパスを返すこと" do
    @esp_raging.preview_path.should == "/pasokara/preview/8340"
    @siawase_gyaku.preview_path.should == "/pasokara/preview/8362"
  end

  it "duration_strが適切な長さを返すこと" do
    pasokara = PasokaraFile.new(@duration_attributes)
    pasokara.duration_str.should == "04:05"
  end

  it "related_tagsが適切に関係するタグを返すこと" do
    tags = PasokaraFile.related_tags(["COOL&CREATE"])
    tags[0].name.should == "COOL&CREATE"
    tags[0].count.should == 2
    tags[1].name.should == "ニコカラ"
    tags[1].count.should == 2
    tags[2].name.should == "あまね"
    tags[2].count.should == 1
  end

end
