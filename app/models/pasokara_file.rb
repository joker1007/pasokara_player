# _*_ coding: utf-8 _*_
require 'kconv'
require 'nkf'
require 'nico_parser/nico_player_parser'

class PasokaraFile < ActiveRecord::Base
  external_encoding "UTF-8" if self.respond_to?(:external_encoding)
  acts_as_taggable_on :tags

  belongs_to :directory
  belongs_to :computer, :include => true
  has_many :users, :through => :favorites
  has_many :sing_logs

  validates_uniqueness_of :md5_hash
  validates_presence_of :name, :md5_hash

  SORT_OPTIONS = [
    ["名前順", "name"],
    ["再生が多い順", "view_count"],
    ["再生が少い順", "view_count_r"],
    ["投稿が新しい順", "post_new"],
    ["投稿が古い順", "post_old"],
    ["マイリスが多い順", "mylist_count"],
  ]

  after_create {|record|
    puts "#{record.class} : #{record.id}を追加しました" unless RAILS_ENV == "test"
  }

  after_update {|record|
    puts "#{record.class} : #{record.id}を更新しました" unless RAILS_ENV == "test"
  }

  def self.related_files(id, limit = 10)
    sql = <<SQL
select c.*, COUNT(b.taggable_id) as count from (select * from taggings a where a.taggable_id = #{id}) t
inner join taggings b on t.tag_id = b.tag_id
inner join pasokara_files c on b.taggable_id = c.id
group by t.taggable_id, b.taggable_id
order by count desc
limit #{limit};
SQL
    PasokaraFile.find_by_sql(sql)
  end

  def name(utf8 = true)
    if utf8
      self["name"]
    else
      NKF.nkf("-W -s --cp932", self["name"])
    end
  end

  def duration_str
    if duration
      (sprintf("%02d", duration / 60)) + ":" + sprintf("%02d", (duration % 60))
    else
      ""
    end
  end

  def movie_path
    extname = File.extname(name)
    "/pasokara/movie/#{id}#{extname}"
  end

  def preview_path
    "/pasokara/preview/#{id}"
  end

  def self.related_tags(tags, limit = 30)

    conditions = tags.map {|tag| "a.name = '#{tag}'"}.join(" OR ")
      
    sql = "select d.id, d.name, COUNT(d.id) as count from (select a.id as id_1, a.name as name_1, b.tag_id, b.taggable_id from tags a inner join taggings b on a.id = b.tag_id where #{conditions} group by b.taggable_id having count(b.taggable_id) = #{tags.size}) t
inner join taggings c on t.taggable_id = c.taggable_id
inner join tags d on c.tag_id = d.id
group by t.id_1, d.id
order by count desc, d.name asc
limit #{limit}"
    Tag.find_by_sql(sql)
  end

end
