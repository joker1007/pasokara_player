require 'drb/drb'
require 'kconv'
require 'cgi'
require 'nkf'
require 'digest/md5'
require './nico_parser/nico_player_parser'
require './nico_parser/api_xml_parser'


WIN32 = RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ? true : false

if WIN32
  $KCODE = 's'
else
  $KCODE = 'u'
end

if ARGV[0] == "-d"
  DEBUG = true
  ARGV.shift
else
  DEBUG = false
end


class DatabaseStructer

  def initialize(hostname = nil)
    puts "キューピッカーサーバーに接続\n"
    @remote_controller = DRbObject.new_with_uri("druby://" + ARGV[0]) #キューピッカーサーバーに接続
    puts "ディレクトリリスト読み込み\n"
    @pasokara_dir = File.open(File.join(File.dirname(__FILE__), "pasokara_dir_setting.txt")) {|file|
      file.readlines
    }.map {|line|
      path = line.chomp.gsub(/\\/, "/").gsub(/\/$/, "")
      if WIN32
        path.tosjis
      else
        path.toutf8
      end
    }[0]
    @hostname = hostname || `hostname`.chomp
    computer_list = @remote_controller.get_computer_list
    computer_list.each do |c_list|
      puts "#{c_list[:id]}: #{c_list[:name]}\n"
    end
    STDOUT.write "Select Computer: "
    select_id = STDIN.gets.to_i
    if select_id > 0
      @computer_id = select_id
    else
      @computer_id = @remote_controller.create_computer({:name => @hostname, :mount_path => @pasokara_dir.toutf8, :remote_path => @pasokara_dir.toutf8})
    end
  end

  def struct
    crowl_dir(@pasokara_dir, @pasokara_dir, @computer_id, nil)
  end

  def crowl_dir(dir, rootdir, computer_id, higher_directory_id = nil)
    puts "#{dir}の読み込み開始\n"

    begin
      open_dir = Dir.open(dir)
      open_dir.entries.each do |entity|
        next if entity =~ /^\./
        entity_fullpath = File.join(dir, entity)

        puts entity_fullpath
        
        if WIN32
          name = NKF.nkf("-Sw --cp932", entity)
          fullpath = WIN32 ? NKF.nkf("-Sw --cp932", dir) + "/" + name
          relative_path = fullpath.gsub(/#{NKF.nkf("-Sw --cp932", rootdir) + "\/"}/, "")
        else
          name = entity
          fullpath = dir + "/" + name
          relative_path = fullpath.gsub(/#{rootdir + "\/"}/, "")
        end

        if File.directory?(entity_fullpath)
          attributes = {:name => name, :fullpath => fullpath, :relative_path => relative_path, :directory_id => higher_directory_id, :computer_id => computer_id}
          if DEBUG
            puts "Attr: "
            puts attributes.inspect
          end

          dir_id = @remote_controller.create_directory(attributes)
          crowl_dir(entity_fullpath, rootdir, computer_id, dir_id)
        elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
          md5_hash = File.open(entity_fullpath) {|file| file.binmode; head = file.read(300*1024); Digest::MD5.hexdigest(head)}
          attributes = {:name => name, :fullpath => fullpath, :relative_path => relative_path, :directory_id => higher_directory_id, :computer_id => computer_id, :md5_hash => md5_hash}
          info_file, parser = check_info_file(entity_fullpath)

          tags = parser.parse_tag(info_file)
          attributes.merge!(parser.parse_info(info_file))

          if DEBUG
            puts "Attr: "
            puts attributes.inspect
            puts "Tags: "
            puts tags.inspect
          end

          pasokara_file_id = @remote_controller.create_pasokara_file(attributes, tags)

          thumb_data = nico_check_thumb(entity_fullpath)
          if thumb_data
            @remote_controller.create_thumbnail_record(pasokara_file_id, thumb_data)
          end
        end
      end
    rescue Errno::ENOENT
      puts "Dir Open Error"
    end
  end

  private

  def check_info_file(fullpath)
    api_xml_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, "_info.xml")
    nico_player_info_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, ".txt")

    if File.exists?(api_xml_file)
      [api_xml_file, NicoParser::ApiXmlParser.new]
    else
      [nico_player_info_file, NicoParser::NicoPlayerParser.new]
    end
  end

  def nico_check_comment(fullpath)
    comment = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".xml")
    if File.exist?(comment)
      {:comment_file => NKF.nkf("-Sw --cp932", comment)}
    else
      {}
    end
  end

  def nico_check_thumb(fullpath)
    thumb = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    if File.exist?(thumb)
      data = File.open(thumb, "wb") {|f| f.read}
    else
      nil
    end
  end
end

DatabaseStructer.new.struct
