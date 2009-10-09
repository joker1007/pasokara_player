# _*_ coding: utf-8 _*_
class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :pasokara_file

  validates_uniqueness_of :user_id, :scope => [:pasokara_file_id]
end
