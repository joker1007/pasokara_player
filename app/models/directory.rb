# _*_ coding: utf-8 _*_
class Directory < ActiveRecord::Base
  include OnlineFind
  has_many :directories, :order => 'name'
  has_many :pasokara_files, :order => 'name'
  belongs_to :directory

  validates_uniqueness_of :fullpath, :scope => [:computer_name]

  def entities
    (directories + pasokara_files)
  end

  def fullpath
    if WIN32
      self["fullpath"].tosjis.gsub(/\//, "\\")
    end
  end

  def fullpath_win
    fullpath
  end

end
