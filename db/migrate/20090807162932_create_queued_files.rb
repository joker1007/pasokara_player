class CreateQueuedFiles < ActiveRecord::Migration
  def self.up
    create_table :queued_files do |t|
      t.integer :pasokara_file_id, :null => false
      t.timestamps
    end
    add_index :queued_files, :pasokara_file_id
  end

  def self.down
    remove_index :queued_files, :pasokara_file_id
    drop_table :queued_files
  end
end
