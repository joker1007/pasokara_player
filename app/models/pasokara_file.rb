# _*_ coding: utf-8 _*_
require 'kconv'
require 'nkf'

class PasokaraFile < ActiveRecord::Base
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  acts_as_taggable_on :tags
  include OnlineFind

  belongs_to :directory
  belongs_to :computer, :include => true
  has_many :users, :through => :favorites

  validates_uniqueness_of :fullpath, :scope => [:computer_id]
  validates_uniqueness_of :md5_hash, :scope => [:computer_id]

  def play
    sleep PRE_SLEEP
    PasokaraNotifier.instance.play_notify(name)
    system(MPC_PATH, fullpath, "/close")
    #system(NICOPLAY_PATH + " \"#{fullpath}\"")
  end

  def play_cmd
    PasokaraNotifier.instance.play_notify(name)
    "\"#{MPC_PATH}\" \"#{fullpath}\" /close"
  end

  def fullpath(utf8 = false)
    if utf8
      self["fullpath"].gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", self["fullpath"]).gsub(/\//, "\\")
    end
  end

  def fullpath_of_computer(utf8 = false)
    if utf8
      (computer.mount_path +  "/" + self["relative_path"]).gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", (computer.mount_path + "/" + self["relative_path"])).gsub(/\//, "\\")
    end
  end

  def thumb_file(utf8 = false)
    if self["thumb_file"]
      if utf8
        self["thumb_file"].gsub(/\343\200\234/, "～")
      else
        NKF.nkf("-Ws --cp932", self["thumb_file"]).gsub(/\//, "\\")
      end
    end
  end

  def movie_path
    extname = File.extname(fullpath)
    "/pasokara/movie/#{id}#{extname}"
  end

  def preview_path
    computer.remote_path + "/pasokara/preview/#{id}"
  end

  def self.related_tags(tags, limit = 30)
    tagged = self.tagged_with(tags, :on => :tags, :match_all => true, :order => "name").find(:all)
    conditions = "taggings.taggable_id IN (" + tagged.map {|p| p.id}.join(",") + ")"
    self.tag_counts(:conditions => conditions, :limit => limit, :order => "count desc, tags.name asc")
  end

  def write_out_tag
    
    unless File.exist?(fullpath)
      return false
    end

    tag_file = directory.fullpath + "/" + File.basename(NKF.nkf("-Ws --cp932", name), ".*") + ".txt"
    buff = ""

    buff += "[tags]\n"
    tag_list.each do |tag|
      buff += tag + "\n"
    end
    
    begin
      File.open(tag_file, "w") {|file|
        file.binmode
        file.write NKF.nkf("-W8 -w16L", buff)
      }
      return true
    rescue Exception
      return false
    end
  end

  def nico_check_tag
    tag_mode = false
    tags = []

    info_file = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    if File.exist?(info_file)
      File.open(info_file) {|file|
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
    tags.each do |tag|
      tag_list.add CGI.unescapeHTML(tag.toutf8)
    end
  end

  def nico_check_info
    parse_mode = false
    info = ""
    info_key = ""

    info_file = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    if File.exist?(info_file)
      File.open(info_file) {|file|
        file.binmode
        converted = NKF.nkf('-W16L -s', file.read)
        converted.each_line do |line|
          if line.chomp.empty?
            parse_mode = false
          end

          if parse_mode == true
            send("nico_#{info_key}=", line.chomp.toutf8)
          end

          if line.chomp =~ /\[(.*)\]/
            next if ($1 == "tags" or $1 == "title" or $1 == "comment")
            parse_mode = true
            info_key = $1
          end
        end
      }
    end
  end

  def nico_check_thumb
    thumb = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    if File.exist?(thumb)
      thumb_file = thumb.toutf8
    end
  end

  def nico_check_comment
    comment = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".xml")
    if File.exist?(comment)
      comment_file = comment.toutf8
    end
  end

end
