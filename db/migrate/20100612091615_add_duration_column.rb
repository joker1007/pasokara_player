class AddDurationColumn < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :duration, :integer, :default => 0
  end

  def self.down
    remove_column :pasokara_files, :duration
  end
end
