require File.dirname(__FILE__) + '/../../config/environment'

namespace :pasokara do
  desc 'Pasokara File DB structure'
  task :struct do
    Directory.struct_all
  end

  desc 'Write Out TagFile from DB'
  task :write_tag do
    PasokaraFile.find(:all).each do |p|
      p.write_out_tag
    end
  end
end

namespace :queue do
  desc 'Queue DB clear'
  task :clear do
    QueuedFile.destroy_all
  end
end
