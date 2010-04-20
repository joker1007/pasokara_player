require 'rubygems'
require 'activerecord'
require 'ruby_gntp'
require 'twitter'
require 'yaml'
require 'kconv'
require 'drb/drb'
require 'config/environment.rb'

if ARGV[0] == "-d"
  DEBUG = true
  ARGV.shift
else
  DEBUG = false
end

AR_ENV = ARGV[1] ? ARGV[1] : "development"

db_setting = YAML.load_file("config/database.yml")

unless db_setting.has_key?(AR_ENV)
  puts "#{AR_ENV} Setting is nothing"
  exit(1)
end

ActiveRecord::Base.establish_connection(db_setting[AR_ENV])

class QueuePickerServer

  def get_file_path(utf8 = false, base_dir = nil)
    begin
      queue = QueuedFile.deq
      if queue
        pasokara = queue.pasokara_file
        puts pasokara.fullpath + "\n"

        # base_dirが与えられていれば、そのディレクトリを基準にしたフルパスを返す
        # 無ければ、レコードに登録されているフルパスを返す
        if base_dir && utf8
          return_path = base_dir + "/" + pasokara.relative_path
        elsif base_dir
          return_path = base_dir + "\\" + pasokara.relative_path(utf8)
        else utf8
          return_path = pasokara.fullpath(utf8)
        end

        PasokaraNotifier.instance.play_notify(pasokara.name)
        return return_path
      end
      return nil
    rescue ActiveRecord::ActiveRecordError
      puts $@
      return nil
    end
  end

  # 最後に登録されたキューを返す。
  # キュー追加のチェック用
  def get_latest_queue(utf8 = false)
    begin
      queue = QueuedFile.find(:first, :order => "id desc")
      if queue
        pasokara = queue.pasokara_file
        puts pasokara.fullpath + "\n"
        return {:id => queue.id, :name => pasokara.name(utf8)}
      end
      return nil
    rescue ActiveRecord::ActiveRecordError
      puts $@
      return nil
    end
  end

  def create_computer(attributes = {})
    begin
      already_record = Computer.find_by_name(attributes[:name])
      return already_record.id if already_record
      
      computer = Computer.new(attributes)
      if computer.save
        print_process computer
        return computer.id
      else
        return nil
      end
    rescue ActiveRecord::ActiveRecordError
      p $@
      raise "ARError"
    end
  end

  def get_computer_list
    computers = Computer.find(:all)
    computers.map {|c|
      {:id => c.id, :name => c.name}
    }
  end

  def create_directory(attributes = {})
    begin
      already_record = Directory.find_by_fullpath_and_computer_id(attributes[:fullpath], attributes[:computer_id])
      directory = Directory.new(attributes)

      if already_record
        if already_record.directory_id != directory.directory_id
          already_record.directory_id = directory.directory_id
          already_record.save
        end

        return already_record.id
      end
      
      if directory.save
        print_process directory
        return directory.id
      else
        return nil
      end
    rescue ActiveRecord::ActiveRecordError
      p $@
      raise "ARError"
    end
  end

  def create_pasokara_file(attributes = {}, tags = [])
    begin
      already_record = PasokaraFile.find_by_md5_hash_and_computer_id(attributes[:md5_hash], attributes[:computer_id])
      pasokara_file = PasokaraFile.new(attributes)
      pasokara_file.tag_list.add tags
      if already_record

        changed = false

        if already_record.name != pasokara_file.name
          already_record.name = pasokara_file.name
          changed = true
        end

        if already_record["fullpath"] != pasokara_file["fullpath"]
          already_record["fullpath"] = pasokara_file["fullpath"]
          changed = true
        end

        if already_record.relative_path != pasokara_file.relative_path
          already_record.relative_path = pasokara_file.relative_path
          changed = true
        end

        if already_record.comment_file != pasokara_file.comment_file
          already_record.comment_file = pasokara_file.comment_file
          changed = true
        end

        if already_record["thumb_file"] != pasokara_file["thumb_file"]
          already_record["thumb_file"] = pasokara_file["thumb_file"]
          changed = true
        end

        if already_record.directory_id != pasokara_file.directory_id
          already_record.directory_id = pasokara_file.directory_id
          changed = true
        end

        if already_record.tag_list.empty? and !pasokara_file.tag_list.empty?
          already_record.tag_list.add pasokara_file.tag_list
          changed = true
        end

        if already_record.nico_name.nil? and !pasokara_file.nico_name.nil?
          already_record.nico_name = pasokara_file.nico_name
          changed = true
        end

        if already_record.nico_post.nil? and !pasokara_file.nico_post.nil?
          already_record.nico_post = pasokara_file.nico_post
          changed = true
        end

        if already_record.nico_view_counter.nil? and !pasokara_file.nico_view_counter.nil?
          already_record.nico_view_counter = pasokara_file.nico_view_counter
          changed = true
        end

        if already_record.nico_comment_num.nil? and !pasokara_file.nico_comment_num.nil?
          already_record.nico_comment_num = pasokara_file.nico_comment_num
          changed = true
        end

        if already_record.nico_mylist_counter.nil? and !pasokara_file.nico_mylist_counter.nil?
          already_record.nico_mylist_counter = pasokara_file.nico_mylist_counter
          changed = true
        end

        if changed
          already_record.save
          print_process already_record
          return already_record.id
        end
      else
        if pasokara_file.save
          print_process pasokara_file
          return pasokara_file.id
        else
          return nil
        end
      end
    rescue ActiveRecord::ActiveRecordError
      p $@
      raise "ARError"
    end
  end

  private
  def print_process(record)
    if DEBUG
      puts record.inspect
    else
      puts "#{record.class}: #{record.id}"
    end
  end

end

WIN32 = RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ? true : false

start_message = "キューピッカーサーバー起動"
if WIN32
  start_message = NKF.nkf("-W -s --cp932", start_message)
end

puts start_message
DRb.start_service("druby://" + ARGV[0], QueuePickerServer.new)
DRb.thread.join
