require 'rubygems'
require 'drb/drb'
require File.join(File.dirname(__FILE__), "notifier/gntp.rb")
require File.join(File.dirname(__FILE__), "notifier/twitter.rb")


WIN32 = RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ? true : false

if WIN32
  $KCODE = 's'
else
  $KCODE = 'u'
end

class QueuePickerClient
  if WIN32
    require 'windows_player'
    include Win::Player
  else
    require 'linux_player'
    include Linux::Player
  end

  attr_accessor :playing

  def initialize
    @remote_queue_picker = DRbObject.new_with_uri("druby://" + ARGV[0]) #キューピッカーサーバーに接続
    @player_thread = nil
    @playing = false
    @current_queue_id = nil

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
        latest_queue = WIN32 ? @remote_queue_picker.get_latest_queue(false) : @remote_queue_picker.get_latest_queue(true)
        if !latest_queue.nil? && @current_queue_id != latest_queue[:id]
          @current_queue_id = latest_queue[:id]
          @latest_queue_name = File.basename(latest_queue[:fullpath])
          queue_notify
        end


        # 再生中はキューの取得を行わない
        unless @playing
          @file_path = WIN32 ? @remote_queue_picker.get_file_path(false) : @remote_queue_picker.get_file_path(true)

          # キューが取得できたら再生処理へ
          if @file_path
            sleep 3
            @file_name = File.basename(@file_path)

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

end

client = QueuePickerClient.new

Thread.new do
  puts "Start Pick up Thread\n"
  client.play_loop
end

DRb.start_service("druby://localhost:12346", client)
puts "Start Queue Picker Client"
sleep
