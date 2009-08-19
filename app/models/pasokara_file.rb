require 'kconv'

class PasokaraFile < ActiveRecord::Base
  belongs_to :directory

  validates_uniqueness_of :fullpath

  def play
    sleep PRE_SLEEP
    #system("echo \"#{Time.now.to_s} - #{fullpath}\" >> /tmp/pasokara_test")
    system(MPC_PATH, fullpath_win.tosjis, "/close")
  end

  def fullpath_win
    fullpath.gsub(/\//, "\\").tosjis
  end
end
