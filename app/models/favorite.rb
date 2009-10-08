# _*_ coding: utf-8 _*_
class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :pasokara_file
end
