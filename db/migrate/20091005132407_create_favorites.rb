class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.integer :user_id, :null => false
      t.integer :pasokara_file_id, :null => false
      t.timestamps
    end
    add_index :favorites, [:user_id, :pasokara_file_id]
  end

  def self.down
    drop_table :favorites
  end
end
