require 'ruby_gntp'

class QueuedFile < ActiveRecord::Base

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

  def play
    sleep PRE_SLEEP
    begin
      @@growl.notify({
        :name => "Play",
        :title => "#{name}",
        :text => "#{name}を再生します",
      })
    rescue Exception
      puts "Growl failed"
    end
    if (TWEET) 
      tweet
    end
    destroy
    #system("echo \"#{Time.now.to_s} - #{fullpath}\" >> /tmp/pasokara_test")
    system(MPC_PATH, fullpath_win, "/close")
  end

  def fullpath_win
    fullpath.gsub(/\//, "\\").tosjis
  end

  def self.enq(pasokara)
    QueuedFile.create :name => pasokara.name, :fullpath => pasokara.fullpath
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
    QueuedFile.find(:first, :order => "created_at")
  end

  private
  def tweet
    begin
      oauth = ::Twitter::OAuth.new('am8c14QPRrO9MZ32M0WoQ', 'BcPeTLZfRBJRigklbTektpisaqxZPuLdi5hg7pX3ows')
      oauth.authorize_from_access('6592592-oerbccD0sozNOrtM1PTSBD5DXoc106paNZJJvawbWz', 'PUKJqbnw4kOsH3xhcixlub4X306M3C3sUtsKjOGA')
      client = ::Twitter::Base.new(oauth)
      client.update("歌ってるなう::#{File.basename(name, ".*")}")
    rescue Exception
      puts "Tweet Failed."
    end
  end

end
