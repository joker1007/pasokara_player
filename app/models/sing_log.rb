class SingLog < ActiveRecord::Base
  belongs_to :pasokara_file
  belongs_to :user
end
