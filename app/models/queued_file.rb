require 'ruby_gntp'

class QueuedFile < ActiveRecord::Base
  belongs_to :pasokara_file

  begin
    @@growl = GNTP.new("Ruby/GNTP Pasokara Player")
    @@growl.register({
      :notifications => [
        {
          :name => "Queue",
          :enabled => true,
        },
        {
          :name => "Play",
          :enabled => true,
        },
      ]
    })
  rescue Exception
    @@growl = nil
    puts "NoGrowl"
  end


  def self.enq(pasokara)
    QueuedFile.create do |q|
      q.pasokara_file = pasokara
    end

    begin
      @@growl.notify({
        :name => "Queue",
        :title => "#{pasokara.name}",
        :text => "#{pasokara.name}を予約しました",
      })
    rescue Exception
      puts "Growl failed"
    end
  end

  def self.deq
    queue = QueuedFile.find(:first, :order => "created_at")
    if queue
      queue.destroy
    end
    queue
  end

end
