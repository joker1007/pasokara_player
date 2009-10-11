# _*_ coding: utf-8 _*_
require "ruby_gntp"
require "twitter"

class PasokaraNotifier
  include Singleton

  def initialize
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

    begin
      oauth = ::Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
      oauth.authorize_from_access(TWITTER_AUTH_KEY, TWITTER_AUTH_SECRET)
      @@twitter = ::Twitter::Base.new(oauth)
    rescue Exception
      @@twitter = nil
      puts "Tweet Failed."
    end
  end

  def play_notify(name)
    begin
      if @@growl
        @@growl.notify({
          :name => "Play",
          :title => "#{name}",
          :text => "#{name}を再生します",
        })
      end

      if TWEET and @@twitter
        @@twitter.update("歌ってるなう::#{File.basename(name, ".*")}")
      end
    rescue Exception
      puts "Notify Failed"
    end
  end

  def queue_notify(name)
    begin
      if @@growl
        @@growl.notify({
          :name => "Queue",
          :title => "#{name}",
          :text => "#{name}を予約しました",
        })
      end
    rescue Exception
      puts "Notify Failed"
    end
  end
end
