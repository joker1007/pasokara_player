# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100320030150) do

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "computers", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "mount_path",                    :null => false
    t.string   "remote_path"
    t.boolean  "online",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "computers", ["name"], :name => "index_computers_on_name", :unique => true
  add_index "computers", ["online"], :name => "index_computers_on_online"

  create_table "directories", :force => true do |t|
    t.string   "name",          :null => false
    t.string   "fullpath",      :null => false
    t.integer  "directory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relative_path", :null => false
    t.integer  "computer_id"
  end

  add_index "directories", ["computer_id"], :name => "index_directories_on_computer_id"
  add_index "directories", ["directory_id"], :name => "index_directories_on_directory_id"
  add_index "directories", ["fullpath", "computer_id"], :name => "index_directories_on_fullpath_and_computer_id", :unique => true

  create_table "favorites", :force => true do |t|
    t.integer  "user_id",          :null => false
    t.integer  "pasokara_file_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["user_id", "pasokara_file_id"], :name => "index_favorites_on_user_id_and_pasokara_file_id"

  create_table "pasokara_files", :force => true do |t|
    t.string   "name",                                :null => false
    t.string   "fullpath",                            :null => false
    t.integer  "directory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relative_path",                       :null => false
    t.string   "comment_file"
    t.string   "thumb_file"
    t.string   "md5_hash",            :default => "", :null => false
    t.string   "nico_name"
    t.datetime "nico_post"
    t.integer  "nico_view_counter"
    t.integer  "nico_comment_num"
    t.integer  "nico_mylist_counter"
    t.integer  "computer_id"
  end

  add_index "pasokara_files", ["computer_id"], :name => "index_pasokara_files_on_computer_id"
  add_index "pasokara_files", ["directory_id"], :name => "index_pasokara_files_on_directory_id"
  add_index "pasokara_files", ["fullpath", "computer_id"], :name => "index_pasokara_files_on_fullpath_and_computer_id", :unique => true
  add_index "pasokara_files", ["md5_hash", "computer_id"], :name => "index_pasokara_files_on_md5_hash_and_computer_id", :unique => true
  add_index "pasokara_files", ["nico_name"], :name => "index_pasokara_files_on_nico_name"
  add_index "pasokara_files", ["nico_post"], :name => "index_pasokara_files_on_nico_post"
  add_index "pasokara_files", ["nico_view_counter"], :name => "index_pasokara_files_on_nico_view_counter"

  create_table "queued_files", :force => true do |t|
    t.integer  "pasokara_file_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "queued_files", ["pasokara_file_id"], :name => "index_queued_files_on_pasokara_file_id"

  create_table "sing_logs", :force => true do |t|
    t.integer  "pasokara_file_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sing_logs", ["pasokara_file_id"], :name => "index_sing_logs_on_pasokara_file_id"
  add_index "sing_logs", ["user_id"], :name => "index_sing_logs_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "users", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
