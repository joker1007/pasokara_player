class SingLog < ActiveRecord::Base
  belongs_to :pasokara_file
  belongs_to :user

  validates_presence_of :pasokara_file_id
end
