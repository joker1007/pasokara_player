require 'rubygems'
require 'activerecord'
require 'twitter'
require 'yaml'
require 'kconv'
require 'config/environment.rb'

AR_ENV = ARGV[0] ? ARGV[0] : "development"

db_setting = YAML.load_file("config/database.yml")

unless db_setting.has_key?(AR_ENV)
  puts "#{AR_ENV} Setting is nothing"
  exit(1)
end

ActiveRecord::Base.establish_connection(db_setting[AR_ENV])

puts "キューピッカー起動"
while true
  begin
    queue = QueuedFile.deq
    if queue
      pasokara = queue.pasokara_file
      puts "Playing:: #{pasokara.name.tosjis}"
      pasokara.play
    end
    sleep 1
  rescue ActiveRecord::ActiveRecordError
    puts $@
  end
end
