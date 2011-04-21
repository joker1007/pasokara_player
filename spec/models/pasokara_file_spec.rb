# _*_ coding: utf-8 _*_
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../db_error_helper')

include DbErrorHelper

describe PasokaraFile do

  # テストデータ作成用メソッド
  def create_pasokara_file(option_attrs = {})
    attrs = {:name => "test001.mp4", :md5_hash => "asdfjl2asjfasd83jasdkfj", :fullpath => File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", "test001.mp4")}
    attrs = attrs.merge(option_attrs)
    PasokaraFile.create(attrs)
  end

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

    @nico_post_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :nico_post => Time.local(2010, 10, 10),
    }

    @nico_name_attributes = {
      :name => "COOL&CREATE - ネココタマツリ.avi",
      :md5_hash => "asdfjl2asjfasd83jasdkfj",
      :nico_name => "sm123456",
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

  describe "値を取得するメソッド " do

    describe "#name()" do
      context "引数無し、または引数がtrueの時" do
        it "UTF-8でnameを返すこと" do
          @siawase_gyaku.name.should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
          @siawase_gyaku.name(true).should == "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv"
        end
      end

      context "引数がfalseの時" do
        it "CP932でnameを返すこと" do
          @siawase_gyaku.name(false).should == NKF.nkf("-W -s --cp932", "【ニコカラ】シアワセうさぎ（逆）(夏) OnVocal.flv")
        end
      end
    end

    describe "#movie_path" do
      it "/video/{idを千の桁で切り捨て}/{id}という形式でファイルパスを返すこと" do
        @esp_raging.movie_path.should == "/video/8000/8340.avi"
        @siawase_gyaku.movie_path.should == "/video/8000/8362.flv"
      end
    end

    describe "#preview_path" do
      it "/pasokara/preview/{id}という形式でファイルパスを返すこと" do
        @esp_raging.preview_path.should == "/pasokara/preview/8340"
        @siawase_gyaku.preview_path.should == "/pasokara/preview/8362"
      end
    end

    describe "#duration_str" do
      it "mm:ss形式で曲の長さを返すこと" do
        pasokara = PasokaraFile.new(@duration_attributes)
        pasokara.duration_str.should == "04:05"
      end
    end

    describe "#nico_post_str" do
      it "yyyy/mm/ddのフォーマットで投稿日時を返すこと" do
        pasokara = PasokaraFile.new(@nico_post_attributes)
        pasokara.nico_post_str.should == "2010/10/10"
      end
    end

    describe "#nico_url" do
      it "ニコニコ動画へのリンクURLを返すこと" do
        pasokara = PasokaraFile.new(@nico_name_attributes)
        pasokara.nico_url.should == "http://www.nicovideo.jp/watch/" + pasokara.nico_name
      end
    end

    describe "#stream_prefix" do
      it "\"{id}-stream\"という文字列を返すこと" do
        id = @esp_raging.id
        @esp_raging.stream_prefix.should == "#{id}-stream"
      end
    end

    describe "#m3u8_filename" do
      it "\"{stream_prefix}.m3u8\"という文字列を返すこと" do
        stream_prefix = @esp_raging.stream_prefix
        @esp_raging.m3u8_filename.should == "#{stream_prefix}.m3u8"
      end
    end

    describe "#m3u8_path" do
      it "\"/video/{m3u8_filename}\"という文字列を返すこと" do
        m3u8_filename = @esp_raging.m3u8_filename
        @esp_raging.m3u8_path.should == "/video/#{m3u8_filename}"
      end
    end
  end

  describe "状態を確認するメソッド " do
    before(:all) do
      @mp4_file = create_pasokara_file
      @no_exist_mp4_file = create_pasokara_file(:fullpath => "/test/nofile.mp4")
      @flv_file = create_pasokara_file(:name => "test002.flv", :fullpath => File.join(File.expand_path(File.dirname(__FILE__)), "..", "datas", "test002.flv"))
      @no_exist_flv_file = create_pasokara_file(:name => "test002.flv", :fullpath => "/test/nofile.flv")
    end

    describe "#mp4?" do
      context "ファイルが存在し、拡張子がmp4のファイルである時" do
        it "trueを返すこと" do
          @mp4_file.mp4?.should be_true
        end
      end
      context "ファイルが存在しない時" do
        it "falseを返すこと" do
          @no_exist_mp4_file.mp4?.should be_false
        end
      end
    end

    describe "#flv?" do
      context "ファイルが存在し、拡張子がflvのファイルである時" do
        it "trueを返すこと" do
          @flv_file.flv?.should be_true
        end
      end
      context "ファイルが存在しない時" do
        it "falseを返すこと" do
          @no_exist_flv_file.flv?.should be_false
        end
      end
    end

    describe "#encoded?" do
      context "エンコードが開始され、m3u8ファイルが存在している時" do
        it "trueを返すこと" do
          p @esp_raging.m3u8_path
          @esp_raging.encoded?.should be_true
        end
      end

      context "m3u8ファイルが存在しない時" do
        it "falseを返すこと" do
          @siawase_gyaku.encoded?.should be_false
        end
      end
    end
  end

  describe "検索するメソッド " do
    describe ".related_tags" do
      it "引数で与えられたタグと関係するタグの配列を返すこと" do
        tags = PasokaraFile.related_tags(["COOL&CREATE"])
        tags[0].name.should == "COOL&CREATE"
        tags[0].count.should == 2
        tags[1].name.should == "ニコカラ"
        tags[1].count.should == 2
        tags[2].name.should == "あまね"
        tags[2].count.should == 1
      end
    end
  end

  describe "#do_encode(host)" do
    it "Resqueオブジェクトにエンコードジョブがenqueueされること" do
      Resque.should_receive(:enqueue).with(Job::VideoEncoder, @esp_raging.id, "host:port")
      @esp_raging.do_encode("host:port")
    end
  end

end
