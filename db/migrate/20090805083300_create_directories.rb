class CreateDirectories < ActiveRecord::Migration
  def self.up
    create_table :directories do |t|
      t.string :name, :null => false
      t.string :fullpath, :null => false
      t.integer :directory_id
      t.timestamps
      t.string :relative_path, :null => false
      t.integer :computer_id
    end
    add_index :directories, [:fullpath, :computer_id], :unique => true
    add_index :directories, :directory_id
    add_index :directories, :computer_id
  end

  def self.down
    drop_table :directories
  end
end
