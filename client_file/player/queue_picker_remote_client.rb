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
    @remote_queue_picker = DRbObject.new_with_uri("druby://" + ARGV[0]) #�L���[�s�b�J�[�T�[�o�[�ɐڑ�
    @player_thread = nil
    @playing = false
    @current_queue_id = nil

    player_setting = File.open(File.join(File.dirname(__FILE__), "pasokara_player_setting.txt")) {|file| file.gets.chop}
    player_setting.gsub!(/%f/, '#{@file_path}')
    player_setting.gsub!(/\\/, "\\\\\\")
    player_setting.gsub!(/\"/, '\"')
  # �Đ��R�}���h��`�B�Đ��Ώۃt�@�C���̃p�X��@file_path�ŎQ�Ƃł���
    self.class.class_eval <<-RUBY
      def play_cmd
        "#{player_setting}"
      end
    RUBY
  end

  def play_loop
    while true
      begin

        # ID�������Ƃ��傫���L���[��ID�ƁA�t�@�C���̃t���p�X���擾���A
        # �ێ����Ă���ID�ƈႤ�l������ꂽ��A�L���[���ǉ����ꂽ�Ɣ��f����B
        # �L���[���ǉ����ꂽ���A���݂̃L���[ID���X�V���A�ʒm���\�b�h���Ă�
        latest_queue = WIN32 ? @remote_queue_picker.get_latest_queue(false) : @remote_queue_picker.get_latest_queue(true)
        if !latest_queue.nil? && @current_queue_id != latest_queue[:id]
          @current_queue_id = latest_queue[:id]
          @latest_queue_name = File.basename(latest_queue[:fullpath])
          queue_notify
        end


        # �Đ����̓L���[�̎擾���s��Ȃ�
        unless @playing
          @file_path = WIN32 ? @remote_queue_picker.get_file_path(false) : @remote_queue_picker.get_file_path(true)

          # �L���[���擾�ł�����Đ�������
          if @file_path
            sleep 3
            @file_name = File.basename(@file_path)

            # �v���[���[�̃v���Z�X�������N�����Ă��Ȃ��ꍇ�A
            # �X���b�h�𐶐����āA��������v���[���[�v���Z�X���N������B
            # �v���[���[�v���Z�X�̎����Ď����s���A�I�����m�F������A
            # �Đ��t���O���I�t�ɂ��āA�X���b�h�ێ��ϐ����N���A����B
            unless @player_thread
              @player_thread = Thread.new do
                puts "PlayerThread start"
                play_start
                play_end
                puts "PlayerThread end"
              end
            # �v���[���[�v���Z�X�����ɋN�����Ă���ꍇ == �O������̒ʒm��
            # �Đ��t���O���I�t�ɂ��ꂽ�ꍇ�A�Đ��R�}���h���s�シ���ɃX���b�h�͏I������B
            # �Đ��t���O���I���ɂ��邪�A���̃X���b�h���ł̓I�t�ɂ��Ȃ��B
            # �v���[���[�I�����A�v���Z�X�N���X���b�h���I�������n���A�Đ��t���O���I�t�ɂ���B
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
