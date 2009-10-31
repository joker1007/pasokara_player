class RemoveComputerNameAndRenameRootpath < ActiveRecord::Migration
  def self.up
    remove_column :directories, :computer_name
    remove_column :pasokara_files, :computer_name
    rename_column :directories, :rootpath, :relative_path
    rename_column :pasokara_files, :rootpath, :relative_path
  end

  def self.down
    add_column :directories, :computer_name, :string
    add_column :pasokara_files, :computer_name, :string
    rename_column :directories, :relative_path, :rootpath
    rename_column :pasokara_files, :relative_path, :rootpath
  end
end
