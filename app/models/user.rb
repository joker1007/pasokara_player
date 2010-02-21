# _*_ coding: utf-8 _*_
class User < ActiveRecord::Base
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  has_many :pasokara_files, :through => :favorites, :order => "pasokara_files.name"
  has_many :favorites

  validates_uniqueness_of :name
end
