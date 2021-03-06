class Tag < ActiveRecord::Base
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
end
