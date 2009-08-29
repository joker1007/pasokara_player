class AddCommentFileAndThumbFile < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :comment_file, :string
    add_column :pasokara_files, :thumb_file, :string
  end

  def self.down
    remove_column :pasokara_files, :comment_file
    remove_column :pasokara_files, :thumb_file
  end
end
