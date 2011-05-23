class AddEncodingToPasokaraFile < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :encoding, :boolean, :default => false
  end

  def self.down
    remove_column :pasokara_files, :encoding
  end
end
