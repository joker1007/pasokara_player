require 'kconv'
require 'ruby_gntp'
require 'twitter'

class PasokaraFile < ActiveRecord::Base
  acts_as_taggable_on :tags

  belongs_to :directory

  validates_uniqueness_of :fullpath

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
    notify
    system(MPC_PATH, fullpath_win, "/close")
    #system(NICOPLAY_PATH + " \"#{fullpath_win}\"")
  end

  def play_cmd
    notify
    "\"#{MPC_PATH}\" \"#{fullpath_win}\" /close"
  end

  def notify
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
  end

  def fullpath_win
    fullpath.gsub(/\//, "\\").tosjis
  end

  def write_out_tag
    tag_file = directory.fullpath_win + "/" + File.basename(name.tosjis, ".*") + ".txt"
    buff = ""

    buff += "[tags]\n"
    tag_list.each do |tag|
      buff += tag + "\n"
    end
    
    begin
      File.open(tag_file, "w") {|file|
        file.binmode
        file.write NKF.nkf("-W8 -w16L", buff)
      }
    rescue Exception
    end
  end

  def nico_check_tag
    tag_mode = false
    tags = []

    info_file = fullpath_win.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    if File.exist?(info_file)
      File.open(info_file) {|file|
        file.binmode
        converted = NKF.nkf('-W16L -s', file.read)
        converted.each_line do |line|
          if line.chop.empty?
            tag_mode = false
          end

          if tag_mode == true
            tags << line.chop
          end

          if line.chop == "[tags]"
            tag_mode = true
          end
        end
      }
    end
    tags
    tags.each do |tag|
      tag_list.add tag.toutf8
    end
  end

  def nico_check_thumb
    thumb = fullpath_win.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    if File.exist?(thumb)
      thumb_file = thumb
    end
  end

  def nico_check_comment
    comment = fullpath_win.gsub(/\.[a-zA-Z0-9]+$/, ".xml")
    if File.exist?(comment)
      comment_file = comment
    end
  end

  private
  def tweet
    begin
      oauth = ::Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
      oauth.authorize_from_access(TWITTER_AUTH_KEY, TWITTER_AUTH_SECRET)
      client = ::Twitter::Base.new(oauth)
      client.update("歌ってるなう::#{File.basename(name, ".*")}")
    rescue Exception
      puts "Tweet Failed."
    end
  end
end
