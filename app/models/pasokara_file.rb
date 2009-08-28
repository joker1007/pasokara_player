require 'kconv'

class PasokaraFile < ActiveRecord::Base
  acts_as_taggable_on :tags

  belongs_to :directory

  validates_uniqueness_of :fullpath

  def play
    sleep PRE_SLEEP
    #system("echo \"#{Time.now.to_s} - #{fullpath}\" >> /tmp/pasokara_test")
    system(MPC_PATH, fullpath_win, "/close")
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
end
