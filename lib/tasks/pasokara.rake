require File.dirname(__FILE__) + '/../../config/environment'

namespace :pasokara do
  desc 'Pasokara File DB structure'
  task :struct do
    Directory.struct_all
  end
end

namespace :queue do
  desc 'Queue DB clear'
  task :clear do
    QueuedFile.destroy_all
  end
end
