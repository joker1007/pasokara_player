require 'drb/drb'
require 'kconv'
require 'nkf'
require 'digest/md5'

$KCODE = 's'

class DatabaseStructer

  def initialize
	puts "キューピッカーサーバーに接続\n"
    @remote_controller = DRbObject.new_with_uri("druby://" + ARGV[0]) #キューピッカーサーバーに接続
	puts "ディレクトリリスト読み込み\n"
    @pasokara_dirs = File.open(File.join(File.dirname(__FILE__), "pasokara_dir_setting.txt")) {|file|
      file.readlines
    }.map {|line| line.chomp}
	@hostname = `hostname`.chomp
  end

  def struct
    @pasokara_dirs.each do |dir|
      crowl_dir(dir, dir, nil)
    end
  end

  def crowl_dir(dir, rootdir, higher_directory_id = nil)
	puts "#{dir}の読み込み開始\n"
    dir = dir.tosjis
    rootdir = rootdir.tosjis


    begin
      open_dir = Dir.open(dir)
      open_dir.entries.each do |entity|
        next if entity =~ /^\./
        entity_fullpath = File.join(dir, entity)

		puts "#{entity_fullpath}\n"

        if File.directory?(entity_fullpath)
		  attributes = {:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id, :computer_name => @hostname}
		  puts "Attr: "
		  p attributes
          dir_id = @remote_controller.create_directory(attributes)
          crowl_dir(entity_fullpath, rootdir, dir_id)
        elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
          md5_hash = File.open(entity_fullpath) {|file| file.binmode; head = file.read(100*1024); Digest::MD5.hexdigest(head)}
          attributes = {:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id, :computer_name => @hostname, :md5_hash => md5_hash}
          tags = nico_check_tag(entity_fullpath)
          attributes.merge!(nico_check_comment(entity_fullpath))
          attributes.merge!(nico_check_thumb(entity_fullpath))
		  puts "Attr: "
		  p attributes
		  puts "Tags: "
		  p tags
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
            tags << line.chop.toutf8
          end

          if line.chop == "[tags]"
            tag_mode = true
          end
        end
      }
    end
    tags
  end

  def nico_check_comment(fullpath)
    comment = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".xml")
    if File.exist?(comment)
      {:comment_file => comment}
    else
      {}
    end
  end

  def nico_check_thumb(fullpath)
    thumb = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    if File.exist?(thumb)
      {:thumb_file => thumb}
    else
      {}
    end
  end
end

DatabaseStructer.new.struct
