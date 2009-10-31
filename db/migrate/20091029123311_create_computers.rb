class CreateComputers < ActiveRecord::Migration
  def self.up
    create_table :computers do |t|
      t.string :name, :null => false
      t.string :mount_path, :null => false
      t.string :remote_path
      t.boolean :online, :default => true
      t.timestamps
    end
    add_index :computers, :online
  end

  def self.down
    drop_table :computers
  end
end
