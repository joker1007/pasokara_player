class FullpathAndRelativePathNullable < ActiveRecord::Migration
  def self.up
    change_column :directories, :fullpath, :string, :null => true
    change_column :directories, :relative_path, :string, :null => true
    change_column :pasokara_files, :fullpath, :string, :null => true
    change_column :pasokara_files, :relative_path, :string, :null => true
  end

  def self.down
    change_column :directories, :fullpath, :string, :null => false
    change_column :directories, :relative_path, :string, :null => false
    change_column :pasokara_files, :fullpath, :string, :null => false
    change_column :pasokara_files, :relative_path, :string, :null => false
  end
end
