# _*_ coding: utf-8 _*_

require "rubygems"
require "sqlite3"
require "digest/md5"

class CreateHashDb
  DBNAME = File.join(File.dirname(__FILE__), "filepath.db")

  unless File.exist?(DBNAME)
    DB = SQLite3::Database.new(DBNAME)
    sql = <<SQL
CREATE TABLE path_table (hash text primary key, filepath text)
SQL
    DB.execute(sql)
  else
    DB = SQLite3::Database.new(DBNAME)
  end

  def self.crowl_dir(dir)
    begin
      open_dir = Dir.open(dir)
    rescue Errno::ENOENT
      puts "Dir Open Error: #{dir}"
      return false
    end

    open_dir.entries.each do |entry|
      next if entry =~ /^\./
      entry_fullpath = File.join(dir, entry)
      if File.directory?(entry_fullpath)
        self.crowl_dir(entry_fullpath)
      elsif File.extname(entry) =~ /(mpg|avi|flv|ogm|mkv|mp4|wmv|swf)/i
        begin
          md5_hash = File.open(entry_fullpath) {|file| file.binmode; head = file.read(300*1024); Digest::MD5.hexdigest(head)}
        rescue Exception
          puts "File Open Error: #{entry_fullpath}"
          next
        end
        sql = <<SQL
INSERT OR REPLACE INTO path_table VALUES(\"#{md5_hash}\", \"#{entry_fullpath}\")
SQL
        puts "#{md5_hash} => #{entry_fullpath}"
        DB.execute(sql)
      end
    end
  end
end

CreateHashDb.crowl_dir(ARGV[0])
