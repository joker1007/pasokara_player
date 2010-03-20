class CreateSingLogs < ActiveRecord::Migration
  def self.up
    create_table :sing_logs do |t|
      t.integer :pasokara_file_id, :null => false
      t.integer :user_id
      t.timestamps
    end
    add_index :sing_logs, :pasokara_file_id
    add_index :sing_logs, :user_id
    execute "ALTER TABLE sing_logs ADD CONSTRAINT fk_sing_logs_pasokara_files FOREIGN KEY (pasokara_file_id) REFERENCES pasokara_files(id)"
    execute "ALTER TABLE sing_logs ADD CONSTRAINT fk_sing_logs_users FOREIGN KEY (user_id) REFERENCES users(id)"
  end

  def self.down
    execute "ALTER TABLE sing_logs DROP FOREIGN KEY fk_sing_logs_pasokara_files"
    execute "ALTER TABLE sing_logs DROP FOREIGN KEY fk_sing_logs_user_id"
    remove_index :sing_logs, :pasokara_file_id
    remove_index :sing_logs, :user_id
    drop_table :sing_logs
  end
end
