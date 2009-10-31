class Computer < ActiveRecord::Base
  has_many :pasokara_files
  has_many :directories

  validates_uniqueness_of :name

  def self.online_find(*args)
    with_scope(:find => {:conditions => ["online = ?", true]}) do
      find(*args)
    end
  end

  def root_entities(options = {})
    options.merge!({:conditions => ["directory_id is null"]})
    dirs = directories.find(:all, options)
    pasokaras = pasokara_files.find(:all, options)
    (dirs + pasokaras)
  end
end
