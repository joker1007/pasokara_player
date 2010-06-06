# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe PasokaraFile do
  fixtures :directories, :pasokara_files, :computers, :taggings, :tags

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
    @esp_raging.preview_path.should == "http://pasokara.example.com/pasokara/preview/8340"
    @siawase_gyaku.preview_path.should == "http://pasokara.example.com/pasokara/preview/8362"
  end

  it "fullpath(true)がUTF-8の適切なフルパスを返すこと" do
    @esp_raging.fullpath.should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.fullpath.should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
    @esp_raging.fullpath(true).should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.fullpath(true).should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
  end

  it "fullpath(false)がCP932の適切なフルパスを返すこと" do
    @esp_raging.fullpath(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ESP RAGING [myu314 remix].avi")
    @siawase_gyaku.fullpath(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv")
  end

  it "fullpath_of_computer(true)がUTF-8の適切なフルパスを返すこと" do
    @esp_raging.fullpath_of_computer.should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.fullpath_of_computer.should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
    @esp_raging.fullpath_of_computer(true).should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.fullpath_of_computer(true).should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
  end

  it "fullpath_of_computer(false)がCP932の適切なフルパスを返すこと" do
    @esp_raging.fullpath_of_computer(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ESP RAGING [myu314 remix].avi")
    @siawase_gyaku.fullpath_of_computer(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv")
  end

  it "relative_path(true)がUTF-8の適切なフルパスを返すこと" do
    @esp_raging.relative_path.should == "COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.relative_path.should == "COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
    @esp_raging.relative_path(true).should == "COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].avi"
    @siawase_gyaku.relative_path(true).should == "COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
  end

  it "relative_pat(false)hがCP932の適切なフルパスを返すこと" do
    @esp_raging.relative_path(false).should == NKF.nkf("-W -s --cp932", "COOL&CREATE\\COOL&CREATE - ESP RAGING [myu314 remix].avi")
    @siawase_gyaku.relative_path(false).should == NKF.nkf("-W -s --cp932", "COOL&CREATE\\【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv")
  end

  it "thumb_file(true)がUTF-8の適切なフルパスを返すこと" do
    @esp_raging.thumb_file.should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].jpg"
    @siawase_gyaku.thumb_file.should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.jpg"
    @esp_raging.thumb_file(true).should == "L:/pasokara/COOL&CREATE/COOL&CREATE - ESP RAGING [myu314 remix].jpg"
    @siawase_gyaku.thumb_file(true).should == "L:/pasokara/COOL&CREATE/【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.jpg"
  end

  it "thumb_file(false)がCP932の適切なフルパスを返すこと" do
    @esp_raging.thumb_file(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\COOL&CREATE - ESP RAGING [myu314 remix].jpg")
    @siawase_gyaku.thumb_file(false).should == NKF.nkf("-W -s --cp932", "L:\\pasokara\\COOL&CREATE\\【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.jpg")
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

  it "write_out_infoがinfoファイルを適切に出力すること" do
    test_fullpath = File.expand_path(File.dirname(__FILE__) + '/../just be friends.mp4')
    write_out_path = File.expand_path(File.dirname(__FILE__) + '/../just be friends.txt')
    @just_be_friends.fullpath = test_fullpath
    @just_be_friends.write_out_info
    File.file?(write_out_path).should be_true
    expected_output = <<FILE
[name]
sm7601746

[post]
2009/07/11 06:06:12

[tags]
ボカロカラオケDB
巡音ルカ
ニコカラ

[view_counter]
3795

[comment_num]
36

[mylist_counter]
132

FILE
    result = File.open(write_out_path) {|file| file.read}
    File.delete(write_out_path)
    result.should == NKF.nkf("-W8 -w16L", expected_output)
  end
end
