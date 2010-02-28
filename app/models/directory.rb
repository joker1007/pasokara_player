# _*_ coding: utf-8 _*_
class Directory < ActiveRecord::Base
  include OnlineFind
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  has_many :directories, :order => 'name'
  has_many :pasokara_files, :order => 'name'
  belongs_to :directory
  belongs_to :computer

  validates_uniqueness_of :fullpath, :scope => [:computer_id]
  validates_presence_of :name, :fullpath, :relative_path

  def entities
    (directories + pasokara_files)
  end

  def fullpath(utf8 = false)
    return nil if self["fullpath"].nil?

    if utf8
      self["fullpath"].gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", self["fullpath"]).gsub(/\//, "\\")
    end
  end

end
