class CreatePasokaraFiles < ActiveRecord::Migration
  def self.up
    create_table :pasokara_files do |t|
      t.string :name, :null => false
      t.string :fullpath, :null => false
      t.integer :directory_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pasokara_files
  end
end
