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
  
  def get_play_cmd
    begin
      queue = QueuedFile.deq
      if queue
        pasokara = queue.pasokara_file
        puts pasokara.play_cmd + "\n"
        return pasokara.play_cmd
      end
      return nil
    rescue ActiveRecord::ActiveRecordError
      puts $@
      return nil
    end
  end

  def get_file_path
    begin
      queue = QueuedFile.deq
      if queue
        pasokara = queue.pasokara_file
        puts pasokara.fullpath + "\n"
        PasokaraNotifier.instance.play_notify(pasokara.name)
        return pasokara.fullpath
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

  def create_directory(attributes = {})
    begin
      already_record = Directory.find_by_fullpath_and_computer_id(attributes[:fullpath], attributes[:computer_id])
      return already_record.id if already_record
      
      directory = Directory.new(attributes)
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

puts "キューピッカーサーバー起動"
DRb.start_service("druby://" + ARGV[0], QueuePickerServer.new)
DRb.thread.join
