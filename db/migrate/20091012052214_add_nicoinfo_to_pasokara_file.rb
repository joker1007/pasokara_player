class AddNicoinfoToPasokaraFile < ActiveRecord::Migration
  def self.up
    add_column :pasokara_files, :nico_name, :string
    add_column :pasokara_files, :nico_post, :timestamp
    add_column :pasokara_files, :nico_view_counter, :integer
    add_column :pasokara_files, :nico_comment_num, :integer
    add_column :pasokara_files, :nico_mylist_counter, :integer
    add_index :pasokara_files, :nico_post
    add_index :pasokara_files, :nico_view_counter
  end

  def self.down
    remove_index :pasokara_files, :nico_post
    remove_index :pasokara_files, :nico_view_counter
    remove_column :pasokara_files, :nico_name
    remove_column :pasokara_files, :nico_post
    remove_column :pasokara_files, :nico_view_counter
    remove_column :pasokara_files, :nico_comment_num
    remove_column :pasokara_files, :nico_mylist_counter
  end
end
