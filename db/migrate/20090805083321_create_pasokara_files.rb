class CreatePasokaraFiles < ActiveRecord::Migration
  def self.up
    create_table :pasokara_files do |t|
      t.string :name, :null => false
      t.integer :directory_id
      t.string :fullpath, :limit => 500
      t.timestamps
      t.column :md5_hash, :"CHAR(32)", :null => false
      t.string :nico_name
      t.timestamp :nico_post
      t.integer :nico_view_counter
      t.integer :nico_comment_num
      t.integer :nico_mylist_counter
      t.integer :duration, :default => 0
      t.string :nico_description, :limit => 1000
    end
    add_index :pasokara_files, :md5_hash 
    add_index :pasokara_files, :directory_id
    add_index :pasokara_files, :nico_name
    add_index :pasokara_files, :nico_post
    add_index :pasokara_files, :nico_view_counter
  end

  def self.down
    drop_table :pasokara_files
  end
end
