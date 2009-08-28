require 'kconv'

class PasokaraFile < ActiveRecord::Base
  acts_as_taggable_on :tags

  belongs_to :directory

  validates_uniqueness_of :fullpath

  def play
    sleep PRE_SLEEP
    #system(MPC_PATH, fullpath_win, "/close")
    system(NICOPLAY_PATH, fullpath_win)
  end

  def fullpath_win
    fullpath.gsub(/\//, "\\").tosjis
  end

  def write_out_tag
    tag_file = directory.fullpath_win + "/" + File.basename(name.tosjis, ".*") + ".txt"
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
    rescue Exception
    end
  end

  def nico_check_tag
    tag_mode = false
    tags = []

    info_file = fullpath_win.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
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
      tag_list.add tag.toutf8
    end
    save
  end
end
