class CreateQueuedFiles < ActiveRecord::Migration
  def self.up
    create_table :queued_files do |t|
      t.integer :pasokara_file_id, :null => false
      t.integer :user_id
      t.timestamps
    end
    add_index :queued_files, :pasokara_file_id
    execute "ALTER TABLE queued_files ADD CONSTRAINT fk_queued_files_on_pasokara_files FOREIGN KEY (pasokara_file_id) REFERENCES pasokara_files(id)"
  end

  def self.down
    execute "ALTER TABLE queued_files DROP FOREIGN KEY fk_queued_files_on_pasokara_files"
    remove_index :queued_files, :pasokara_file_id
    drop_table :queued_files
  end
end
