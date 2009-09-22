require 'rubygems'
require 'drb/drb'
require 'win32/process'

$KCODE = 's'

include Windows::Synchronize
include Windows::Process
include Windows::Handle

class QueuePickerClient
  attr_accessor :playing

  def initialize
    @remote_queue_picker = DRbObject.new_with_uri("druby://" + ARGV[0]) #�L���[�s�b�J�[�T�[�o�[�ɐڑ�
	@remote_queue_picker.add_online_computer(`hostname`.chomp)
    @player_thread = nil
    @playing = false
	
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
      # �Đ����̓L���[�̎擾���s��Ȃ�
      unless @playing
        @file_path = @remote_queue_picker.get_file_path

        # �L���[���擾�ł�����Đ�������
        if @file_path
          sleep 3
          # �v���[���[�̃v���Z�X�������N�����Ă��Ȃ��ꍇ�A
          # �X���b�h�𐶐����āA��������v���[���[�v���Z�X���N������B
          # �v���[���[�v���Z�X�̎����Ď����s���A�I�����m�F������A
          # �Đ��t���O���I�t�ɂ��āA�X���b�h�ێ��ϐ����N���A����B
          unless @player_thread
            @player_thread = Thread.new do
              puts "PlayerThread start"
              @playing = true
              puts "Play Start" + Thread.current.inspect
              puts play_cmd
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
    end
  end


end

client = QueuePickerClient.new

Thread.new do
  puts "Start Pick up Thread\n"
  client.play_loop
end

DRb.start_service("druby://localhost:12346", client)
puts "�L���[�s�b�J�[�N���C�A���g�N��"
sleep
