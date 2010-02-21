class AddComputerIdToDirectory < ActiveRecord::Migration
  def self.up
    add_column :directories, :computer_id, :integer
    add_index :directories, :computer_id
    add_index :directories, [:fullpath, :computer_id], :unique => true
  end

  def self.down
    remove_index :directories, [:fullpath, :computer_id]
    remove_index :directories, :computer_id
    remove_column :directories, :computer_id
  end
end
