class CreateDlFeeds < ActiveRecord::Migration
  def self.up
    create_table :dl_feeds do |t|
      t.string :url, :null => false
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :dl_feeds
  end
end
