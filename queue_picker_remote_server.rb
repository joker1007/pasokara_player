require 'rubygems'
require 'activerecord'
require 'ruby_gntp'
require 'twitter'
require 'yaml'
require 'kconv'
require 'drb/drb'
require 'config/environment.rb'

AR_ENV = ARGV[1] ? ARGV[1] : "development"

db_setting = YAML.load_file("config/database.yml")

unless db_setting.has_key?(AR_ENV)
  puts "#{AR_ENV} Setting is nothing"
  exit(1)
end

ActiveRecord::Base.establish_connection(db_setting[AR_ENV])

class QueuePickerServer
  attr_reader :online_computers

  def initialize
    @online_computers = []
  end

  def add_online_computer(computer_name)
    @online_computers << computer_name
  end
  
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
        puts pasokara.fullpath_win + "\n"
        PasokaraNotifier.instance.play_notify(pasokara.name)
        return pasokara.fullpath_win
      end
      return nil
    rescue ActiveRecord::ActiveRecordError
      puts $@
      return nil
    end
  end

  def create_directory(attributes = {})
    directory = Directory.new(attributes)
    if directory.save
      puts directory.inspect
      return directory.id
    else
      return nil
    end
  end

  def create_pasokara_file(attributes = {}, tags = [])
    pasokara_file = PasokaraFile.new(attributes)
    pasokara_file.tag_list.add tags
    if pasokara_file.save
      puts pasokara_file.inspect
      return pasokara_file.id
    else
      return nil
    end
  end

end

puts "キューピッカーサーバー起動"
DRb.start_service("druby://" + ARGV[0], QueuePickerServer.new)
sleep
