class RemoveFullpathRelativePathConstraint < ActiveRecord::Migration
  def self.up
    remove_index :directories, [:fullpath, :computer_id]
    remove_index :pasokara_files, [:fullpath, :computer_id]
    remove_index :pasokara_files, [:md5_hash, :computer_id]
  end

  def self.down
    add_index :directories, [:fullpath, :computer_id], :unique => true
    add_index :pasokara_files, [:fullpath, :computer_id], :unique => true
    add_index :pasokara_files, [:md5_hash, :computer_id], :unique => true
  end
end
