require 'drb/drb'
require 'kconv'
require 'cgi'
require 'nkf'
require 'digest/md5'


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
        
        name = NKF.nkf("-Sw --cp932", entity)
        fullpath = NKF.nkf("-Sw --cp932", dir) + "/" + NKF.nkf("-Sw --cp932", entity)
        relative_path = fullpath.gsub(/#{NKF.nkf("-Sw --cp932", rootdir) + "\/"}/, "")

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
          tags = nico_check_tag(entity_fullpath)
          attributes.merge!(nico_check_info(entity_fullpath))
          attributes.merge!(nico_check_comment(entity_fullpath))
          attributes.merge!(nico_check_thumb(entity_fullpath))
          if DEBUG
		    puts "Attr: "
		    puts attributes.inspect
		    puts "Tags: "
		    puts tags.inspect
          end
          pasokara_file_id = @remote_controller.create_pasokara_file(attributes, tags)
        end
      end
    rescue Errno::ENOENT
      puts "Dir Open Error"
    end
  end

  private
  def nico_check_tag(fullpath)
    tag_mode = false
    tags = []

    info_file = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    if File.exist?(info_file)
      File.open(info_file) {|file|
        file.binmode
        converted = NKF.nkf('-W16L -s', file.read)
        converted.each_line do |line|
          if line.chop.empty?
            tag_mode = false
          end

          if tag_mode == true
            tags << CGI.unescapeHTML(line.chop.toutf8)
          end

          if line.chop == "[tags]"
            tag_mode = true
          end
        end
      }
    end
    tags
  end

  def nico_check_info(fullpath)
    parse_mode = false
    info = {}
    info_key = ""
    valid_keys = ["name", "post", "view_counter", "comment_num", "mylist_counter"]

    info_file = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    if File.exist?(info_file)
      File.open(info_file) {|file|
        file.binmode
        converted = NKF.nkf('-W16L -s', file.read)
        converted.each_line do |line|
          if line.chomp.empty?
            parse_mode = false
          end

          if parse_mode == true
            info.merge!({"nico_#{info_key}".to_sym => line.chomp.toutf8})
          end

          if line.chomp =~ /\[(.*)\]/
            next unless valid_keys.include?($1)
            parse_mode = true
            info_key = $1
          end
        end
      }
    end
    info
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
      {:thumb_file => NKF.nkf("-Sw --cp932", thumb)}
    else
      {}
    end
  end
end

DatabaseStructer.new.struct
