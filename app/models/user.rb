# _*_ coding: utf-8 _*_
class User < ActiveRecord::Base
  has_many :pasokara_files, :through => :favorites
end
