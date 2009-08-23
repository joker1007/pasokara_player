class Directory < ActiveRecord::Base
  has_many :directories, :order => 'name'
  has_many :pasokara_files, :order => 'name'
  belongs_to :directory

  validates_uniqueness_of :fullpath

  def entities
    (directories + pasokara_files)
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

    begin
      open_dir = Dir.open(dir)
      open_dir.entries.each do |entity|
        next if entity =~ /^\./

        if File.directory?(dir + "/" + entity)
          dir_obj = Directory.create(:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id)
          crowl_dir(dir_obj.fullpath, rootdir, dir_obj.id)
        elsif File.extname(entity) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
          pasokara_file = PasokaraFile.create(:name => entity.toutf8, :fullpath => dir.toutf8 + "/" + entity.toutf8, :rootpath => rootdir.toutf8, :directory_id => higher_directory_id)
          tags = self.nico_check(entity, dir)
          tags.each do |tag|
            pasokara_file.tag_list.add tag.toutf8
          end
          pasokara_file.save
        end
      end
    rescue Errno::ENOENT
      puts "Dir Open Error"
    end
  end

  def self.nico_check(entity, dir)
    tag_mode = false
    tags = []

    info_file = File.basename(entity, ".*") + ".txt"
    if File.exist?(dir + "/" + info_file)
      File.open(dir + "/" + info_file) {|file|
        file.binmode
        converted = NKF.nkf('-W16L -s', file.read)
        converted.each_line do |line|
          if line.chop.empty?
            tag_mode = false
          end

          if tag_mode == true
            tags << line.chop
          end

          if line.chop == "[tags]"
            tag_mode = true
          end
        end
      }
    end
    tags
  end
end
