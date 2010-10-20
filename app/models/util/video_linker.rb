# encoding: utf-8
module Util
  module VideoLinker
  
    def self.create_links
      pasokaras = PasokaraFile.all(:select => "id, fullpath")
      system("rm -rf #{File.join(RAILS_ROOT, "public", "video","*")}")
      pasokaras.each do |pasokara|
        extname = File.extname(pasokara.fullpath)
        subdir = ((pasokara.id / 1000) * 1000).to_s
        unless File.exist?(File.join(RAILS_ROOT, "public", "video", subdir))
          Dir.mkdir(File.join(RAILS_ROOT, "public", "video", subdir))
        end
        puts "#{pasokara.fullpath} => #{File.join(RAILS_ROOT, "public", "video", subdir, pasokara.id.to_s + extname)}"
        system("ln -s \"#{pasokara.fullpath}\" #{File.join(RAILS_ROOT, "public", "video", subdir, pasokara.id.to_s + extname)}")
      end
    end
  end
end
