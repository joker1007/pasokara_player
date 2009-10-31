class AddComputerIdToPasokaraFile < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :computer_id, :integer
    add_index :pasokara_files, :computer_id
  end

  def self.down
    remove_index :pasokara_files, :computer_id
    remove_column :pasokara_files, :computer_id
  end
end
