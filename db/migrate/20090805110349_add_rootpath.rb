class AddRootpath < ActiveRecord::Migration
  def self.up
    add_column :directories, :rootpath, :string, :nil => false
    add_column :pasokara_files, :rootpath, :string, :nil => false
  end

  def self.down
    remove_column :directories, :rootpath
    remove_column :pasokara_files, :rootpath
  end
end
