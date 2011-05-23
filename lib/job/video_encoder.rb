module Job
  class VideoEncoder
    @queue = :default

    def self.perform(id, host)
      segmenter_duration = "5"

      pasokara = PasokaraFile.find(id)
      pasokara.encoding = true
      pasokara.save
      input_file = pasokara.fullpath
      aspect = `#{RAILS_ROOT}/lib/job/get_info.sh "#{input_file}"`.chomp
      system("#{RAILS_ROOT}/lib/job/video_encoder.sh", input_file, "#{RAILS_ROOT}/public/video", aspect.to_s, aspect.to_s, segmenter_duration, pasokara.stream_prefix, "http://#{host}/video")
      pasokara.encoding = false
      pasokara.save
    end
  end
end

