class AddDescriptionColumn < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :nico_description, :text
  end

  def self.down
    remove_column :pasokara_files, :nico_description
  end
end
