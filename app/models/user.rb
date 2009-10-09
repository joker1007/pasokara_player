# _*_ coding: utf-8 _*_
class User < ActiveRecord::Base
  has_many :pasokara_files, :through => :favorites, :order => "pasokara_files.name"
  has_many :favorites

  validates_uniqueness_of :name
end
