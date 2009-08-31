require 'rubygems'
require 'activerecord'
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
  
  def get_play_cmd
    begin
      queue = QueuedFile.deq
      if queue
        pasokara = queue.pasokara_file
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
        pasokara.notify
        return pasokara.fullpath_win
      end
      return nil
    rescue ActiveRecord::ActiveRecordError
      puts $@
      return nil
    end
  end

end

puts "キューピッカーサーバー起動"
DRb.start_service("druby://" + ARGV[0], QueuePickerServer.new)
sleep
