require 'rubygems'
require 'drb/drb'
require 'win32/process'

include Windows::Synchronize
include Windows::Process
include Windows::Handle

class QueuePickerClient
  attr_accessor :playing

  def initialize
    @remote_queue_picker = DRbObject.new_with_uri("druby://" + ARGV[0]) #キューピッカーサーバーに接続
    @player_thread = nil
    @playing = false
  end

  def play_loop
    while true
      # 再生中はキューの取得を行わない
      unless @playing
        @file_path = @remote_queue_picker.get_file_path

        # キューが取得できたら再生処理へ
        if @file_path
          sleep 3
          # プレーヤーのプロセスが未だ起動していない場合、
          # スレッドを生成して、そこからプレーヤープロセスを起動する。
          # プレーヤープロセスの死活監視を行い、終了を確認したら、
          # 再生フラグをオフにして、スレッド保持変数をクリアする。
          unless @player_thread
            @player_thread = Thread.new do
              puts "PlayerThread start"
              @playing = true
              puts "Play Start" + Thread.current.inspect
              pi = Process.create("app_name" => play_cmd)
              handle = OpenProcess(PROCESS_ALL_ACCESS, 0, pi.process_id)
              until WaitForSingleObject(handle, 0) == WAIT_OBJECT_0
                sleep 1
              end
              CloseHandle(handle)
              puts "Play End" + Thread.current.inspect
              @playing = false
              @player_thread = nil
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
    end
  end

  # 再生コマンド定義。再生対象ファイルのパスは@file_pathで参照できる
  def play_cmd
    'G:\nicoplayer\NicoPlayer.exe' + ' ' + "\"#{@file_path}\""
  end

end

client = QueuePickerClient.new

Thread.new do
  puts "Start Pick up Thread\n"
  client.play_loop
end

DRb.start_service("druby://localhost:12346", client)
puts "キューピッカークライアント起動"
sleep
