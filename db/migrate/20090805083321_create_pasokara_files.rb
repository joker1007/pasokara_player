class CreatePasokaraFiles < ActiveRecord::Migration
  def self.up
    create_table :pasokara_files do |t|
      t.string :name, :null => false
      t.string :fullpath, :null => false
      t.integer :directory_id
      t.timestamps
      t.string :relative_path, :null => false
      t.string :comment_file
      t.string :thumb_file
      t.string :md5_hash, :null => false
      t.string :nico_name
      t.timestamp :nico_post
      t.integer :nico_view_counter
      t.integer :nico_comment_num
      t.integer :nico_mylist_counter
      t.integer :computer_id
    end
    add_index :pasokara_files, [:fullpath, :computer_id], :unique => true
    add_index :pasokara_files, [:md5_hash, :computer_id], :unique => true
    add_index :pasokara_files, :directory_id
    add_index :pasokara_files, :nico_name
    add_index :pasokara_files, :nico_post
    add_index :pasokara_files, :nico_view_counter
    add_index :pasokara_files, :computer_id
  end

  def self.down
    drop_table :pasokara_files
  end
end
