# _*_ coding: utf-8 _*_
require 'rubygems'
require 'drb/drb'
require 'net/http'
require 'time'
require 'sqlite3'
require 'rexml/document'
require 'rexml/streamlistener'

require File.join(File.dirname(__FILE__), "notifier/gntp.rb")
require File.join(File.dirname(__FILE__), "notifier/twitter.rb")


# 実行環境がWindowsか判別
WIN32 = RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ? true : false

# Windowsなら文字コードをSJISにセットする。
if WIN32
  $KCODE = 's'
else
  $KCODE = 'u'
end

# リモートから取得したデータをオブジェクト化するため、事前定義する
class PasokaraFile
  attr_accessor :id, :name, :nico_name, :md5_hash
end

# 取得したXMLをパースし、PasokaraFileオブジェクトを作る
class QueueListener
  include REXML::StreamListener

  def initialize
    @pasokara = PasokaraFile.new
  end

  def tag_start(tag, attrs)
    @current_tag = tag.gsub(/-/, "_")
    @current_attrs = attrs
  end

  def text(text)
    if @current_tag =~ /(^id$|^name$|nico_name|md5_hash)/
      unless @current_attrs.empty?
        case @current_attrs["type"]
        when "integer"
          val = text.to_i
        when "datetime"
          val = Time.parse(text)
        end
      else
        val = text
      end

      @pasokara.send("#{@current_tag}=", val)
    end
  end

  def pasokara
    @pasokara
  end

  def tag_end(tag)
    @current_tag = nil
    @current_attrs = nil
  end
end


class QueuePicker

  # プレーヤープロセスの生成、監視方法を、プラットフォームで切り替える。
  if WIN32
    require File.join(File.dirname(__FILE__), "player/windows_player")
    include Win::Player
  else
    require File.join(File.dirname(__FILE__), "player/linux_player")
    include Linux::Player
  end

  def initialize
    unless File.exist?(File.join(File.dirname(__FILE__), "filepath.db"))
      puts "Database Not Found"
      exit 1
    end

    @http = Net::HTTP::Proxy(nil).new(ARGV[0], ARGV[1])
    @player_thread = nil
    @playing = false
    @current_queue_id = nil
    @base_dir = ARGV[2]
    @db = SQLite3::Database.new(File.join(File.dirname(__FILE__), "filepath.db"))

    player_setting = File.open(File.join(File.dirname(__FILE__), "pasokara_player_setting.txt")) {|file| file.gets.chop}
    player_setting.gsub!(/%f/, '#{@file_path}')
    player_setting.gsub!(/\\/, "\\\\\\")
    player_setting.gsub!(/\"/, '\"')

  # 再生コマンド定義。再生対象ファイルのパスは@file_pathで参照できる
    self.class.class_eval <<-RUBY
      def play_cmd
        "#{player_setting}"
      end
    RUBY
  end

  def play_loop
    while true
      begin

        # IDがもっとも大きいキューのIDと、ファイルのフルパスを取得し、
        # 保持しているIDと違う値が得られたら、キューが追加されたと判断する。
        # キューが追加された時、現在のキューIDを更新し、通知メソッドを呼ぶ
        latest_queue = get_latest_queue
        if !latest_queue.nil? && @current_queue_id != latest_queue.id
          @current_queue_id = latest_queue.id
          @latest_queue_name = File.basename(latest_queue.name)
          queue_notify
        end


        # 再生中はキューの取得を行わない
        unless @playing
          queue = get_queue

          # キューが取得できたら再生処理へ
          if queue
            @file_path = @db.get_first_value("select filepath from path_table where hash = \"#{queue.md5_hash}\"")

            sleep 3
            @file_name = File.basename(queue.name)

            # プレーヤーのプロセスが未だ起動していない場合、
            # スレッドを生成して、そこからプレーヤープロセスを起動する。
            # プレーヤープロセスの死活監視を行い、終了を確認したら、
            # 再生フラグをオフにして、スレッド保持変数をクリアする。
            unless @player_thread
              @player_thread = Thread.new do
                puts "PlayerThread start"
                play_start
                play_end
                puts "PlayerThread end"
              end
            # プレーヤープロセスが既に起動している場合 == 外部からの通知で
            # 再生フラグがオフにされた場合、再生コマンド実行後すぐにスレッドは終了する。
            # 再生フラグをオンにするが、このスレッド内ではオフにしない。
            # プレーヤー終了時、プロセス起動スレッドが終了を検地し、再生フラグをオフにする。
            else
              Thread.new do
                @playing = true
                puts "Play Start(notifier)" + Thread.current.inspect
                system(play_cmd)
                puts "Play End(notifier)" + Thread.current.inspect
              end
            end
          end
        end
        sleep 3
      rescue
        puts $!
        puts $@
      end
    end
  end

  protected
  def play_start
    @playing = true
    puts "Play Start"
    puts play_cmd
    play_notify
    launch_player(play_cmd)
  end
  
  def play_end
    puts "Play End"
    @playing = false
    @player_thread = nil
  end

  def play_notify
    Notifier::Gntp.instance.play_notify(@file_name)
  end

  def queue_notify
    Notifier::Gntp.instance.queue_notify(@latest_queue_name)
  end

  def get_latest_queue
    @http.start {|h|
      res, body = h.get("/queue/last.xml")
      if res.code == "200"
        listener = QueueListener.new
        REXML::Parsers::StreamParser.new(body, listener).parse
        pasokara = listener.pasokara
        return pasokara
      else
        return nil
      end
    }
  end

  def get_queue
    @http.start {|h|
      res, body = h.get("/queue/deque.xml")
      if res.code == "200"
        listener = QueueListener.new
        REXML::Parsers::StreamParser.new(body, listener).parse
        pasokara = listener.pasokara
        return pasokara
      else
        return nil
      end
    }
  end

end

client = QueuePicker.new
puts "Start Queue Picker Client"
client.play_loop
