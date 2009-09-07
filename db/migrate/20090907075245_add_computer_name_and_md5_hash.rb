class AddComputerNameAndMd5Hash < ActiveRecord::Migration
  def self.up
    add_column :directories, :computer_name, :string
    add_column :pasokara_files, :computer_name, :string
    add_column :pasokara_files, :md5_hash, :string, :size => 40, :default => "", :null => false
    add_index :directories, :computer_name
    add_index :pasokara_files, :computer_name
  end

  def self.down
  end
end
