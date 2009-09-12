# _*_ coding: utf-8 _*_
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

namespace :page_cache do
  desc 'Page Cache Clear'
  task :clear do
    FileUtils.rm(File.join(RAILS_ROOT, "public", "index.html")) if File.exist?(File.join(RAILS_ROOT, "public", "index.html"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "dir")) if File.exist?(File.join(RAILS_ROOT, "public", "dir"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "search")) if File.exist?(File.join(RAILS_ROOT, "public", "search"))
    FileUtils.rm_r(File.join(RAILS_ROOT, "public", "tag_search")) if File.exist?(File.join(RAILS_ROOT, "public", "tag_search"))
  end
end
