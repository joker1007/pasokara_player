class AddComputerIdToPasokaraFile < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :computer_id, :integer
    add_index :pasokara_files, :computer_id
    add_index :pasokara_files, [:fullpath, :computer_id], :unique => true
    add_index :pasokara_files, [:md5_hash, :computer_id], :unique => true
  end

  def self.down
    remove_index :pasokara_files, [:fullpath, :computer_id]
    remove_index :pasokara_files, [:md5_hash, :computer_id]
    remove_index :pasokara_files, :computer_id
    remove_column :pasokara_files, :computer_id
  end
end
