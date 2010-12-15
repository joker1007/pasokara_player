class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :null => false
      t.string :twitter_access_token
      t.string :twitter_access_secret
      t.boolean :tweeting, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
