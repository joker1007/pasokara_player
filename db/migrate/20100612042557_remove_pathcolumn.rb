class RemovePathcolumn < ActiveRecord::Migration
  def self.up
    remove_column :pasokara_files, :fullpath
    remove_column :pasokara_files, :relative_path
    remove_column :pasokara_files, :comment_file
    remove_column :pasokara_files, :thumb_file
    remove_index :pasokara_files, :computer_id
    remove_column :pasokara_files, :computer_id

    remove_column :directories, :fullpath
    remove_column :directories, :relative_path
    remove_index :directories, :computer_id
    remove_column :directories, :computer_id
  end

  def self.down
    add_column :pasokara_files, :fullpath, :string
    add_column :pasokara_files, :relative_path, :string
    add_column :pasokara_files, :comment_file, :string
    add_column :pasokara_files, :thumb_file, :string
    add_index :pasokara_files, :computer_id, :integer
    add_column :pasokara_files, :computer_id, :integer

    add_column :directories, :fullpath, :string
    add_column :directories, :relative_path, :string
    add_index :directories, :computer_id, :integer
    add_column :directories, :computer_id, :integer
  end
end
