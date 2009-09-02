class Directory < ActiveRecord::Base
  has_many :directories, :order => 'name'
  has_many :pasokara_files, :order => 'name'
  belongs_to :directory

  validates_uniqueness_of :fullpath

  def entities
    (directories + pasokara_files)
  end

  def fullpath_win
    fullpath.gsub(/\//, "\\").tosjis
  end

  def self.struct_all(force = false)
    if force
      self.destroy_all
      PasokaraFile.destroy_all
    end

    ::PASOKARA_DIRS.each do |dir|
      self.struct(dir)
    end
  end

  def self.struct(dir, force = false)
    if force
      self.destroy_all
      PasokaraFile.destroy_all
    end
    
    self.crowl_dir(dir, dir)
  end

  def self.crowl_dir(dir, rootdir, higher_directory_id = nil)
    if WIN32
      dir = dir.tosjis
      rootdir = rootdir.tosjis
    end
    
    puts "#{dir}の読み込みを開始".tosjis

    begin
      open_dir = Dir.open(dir)
      open_dir.entries.each do |entity|
        next if entity =~ /^\./

        puts entity

        if File.directory?(dir + "/" + entity)
          dir_obj = Directory.create(:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id)
          puts dir_obj.inspect
          crowl_dir(dir_obj.fullpath, rootdir, dir_obj.id)
        elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
          pasokara_file = PasokaraFile.new(:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id)
          pasokara_file.nico_check_tag
          pasokara_file.nico_check_thumb
          pasokara_file.nico_check_comment
          pasokara_file.save
          puts pasokara_file.inspect
          puts pasokara_file.tag_list.inspect
        end
      end
    rescue Errno::ENOENT
      puts "Dir Open Error"
    end
  end

end
