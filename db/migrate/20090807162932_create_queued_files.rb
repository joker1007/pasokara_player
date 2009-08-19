class CreateQueuedFiles < ActiveRecord::Migration
  def self.up
    create_table :queued_files do |t|
      t.string :name, :null => false
      t.string :fullpath, :null => false
      t.boolean :finished, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :queued_files
  end
end
