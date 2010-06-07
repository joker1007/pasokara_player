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

  SORT_OPTIONS = [
    ["名前順", "name"],
    ["再生が多い順", "view_count"],
    ["再生が少い順", "view_count_r"],
    ["投稿が新しい順", "post_new"],
    ["投稿が古い順", "post_old"],
    ["マイリスが多い順", "mylist_count"],
  ]

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

  def play
    sleep PRE_SLEEP
    PasokaraNotifier.instance.play_notify(name)
    system(MPC_PATH, fullpath, "/close")
    #system(NICOPLAY_PATH + " \"#{fullpath}\"")
  end

  def play_cmd
    PasokaraNotifier.instance.play_notify(name)
    "\"#{MPC_PATH}\" \"#{fullpath}\" /close"
  end

  def name(utf8 = true)
    if utf8
      self["name"]
    else
      NKF.nkf("-W -s --cp932", self["name"])
    end
  end

  def fullpath(utf8 = true)
    return nil if self["fullpath"].nil?

    if utf8
      self["fullpath"].gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", self["fullpath"]).gsub(/\//, "\\")
    end
  end

  def fullpath_of_computer(utf8 = true)
    return nil if self["fullpath"].nil?

    if utf8
      (computer.mount_path +  "/" + self["relative_path"]).gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", (computer.mount_path + "/" + self["relative_path"])).gsub(/\//, "\\")
    end
  end

  def relative_path(utf8 = true)
    return nil if self["relative_path"].nil?

    if utf8
      self["relative_path"].gsub(/\343\200\234/, "～")
    else
      NKF.nkf("-Ws --cp932", self["relative_path"]).gsub(/\//, "\\")
    end
  end

  def thumb_file(utf8 = true)
    return nil if self["thumb_file"].nil?

    if self["thumb_file"]
      if utf8
        self["thumb_file"].gsub(/\343\200\234/, "～")
      else
        NKF.nkf("-Ws --cp932", self["thumb_file"]).gsub(/\//, "\\")
      end
    end
  end

  def movie_path
    extname = File.extname(fullpath)
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

  def write_out_info
    info_set = {:nico_name => nico_name, :nico_post => nico_post, :nico_view_counter => nico_view_counter, :nico_comment_num => nico_comment_num, :nico_mylist_counter => nico_mylist_counter}
    tags = tag_list
    info_str = NicoParser::NicoPlayerParser.info_str(info_set, tags)

    info_file = fullpath.gsub(/\.[0-9a-zA-Z]+$/, ".txt")
    unless File.exist?(info_file)
      File.open(info_file, "w") {|file| file.write info_str}
    end
  end

  def nico_check_tag
    info_file = pasokara_file.fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    tags = NicoParser::NicoPlayerParser.parse_tag(info_file)
    tag_list.add tags
  end

  def nico_check_info
    info_file = pasokara_file.fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".txt")
    info_set = NicoParser::NicoPlayerParser.parse_info(info_file)
    attributes = info_set
  end

  def nico_check_thumb
    thumb = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".jpg")
    if File.exist?(thumb)
      thumb_file = thumb.toutf8
    end
  end

  def nico_check_comment
    comment = fullpath.gsub(/\.[a-zA-Z0-9]+$/, ".xml")
    if File.exist?(comment)
      comment_file = comment.toutf8
    end
  end

end
