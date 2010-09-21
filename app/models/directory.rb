# _*_ coding: utf-8 _*_
class Directory < ActiveRecord::Base
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  has_many :directories, :order => 'name'
  has_many :pasokara_files, :order => 'name'
  belongs_to :directory
  belongs_to :computer

  validates_presence_of :name

  after_create {|record|
    puts "#{record.class} : #{record.id}を追加しました" unless RAILS_ENV == "test"
  }

  def entities
    (directories + pasokara_files)
  end

end
