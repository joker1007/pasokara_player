# _*_ coding: utf-8 _*_

require "solr"

module Util
  class SolrIndexer

    def self.indexing
      solr = Solr::Connection.new("http://#{SOLR_SERVER}/solr")
      PasokaraFile.all.each do |pasokara|
        puts pasokara.id.to_s + ":" + pasokara.name
        solr_key = {}
        solr_key.merge!({:id => pasokara.id})
        solr_key.merge!({:name => pasokara.name}) if pasokara.name
        solr_key.merge!({:nico_name => pasokara.nico_name}) if pasokara.nico_name
        solr_key.merge!({:nico_view_counter => pasokara.nico_view_counter}) if pasokara.nico_view_counter
        solr_key.merge!({:nico_comment_num => pasokara.nico_comment_num}) if pasokara.nico_comment_num
        solr_key.merge!({:nico_mylist_counter => pasokara.nico_mylist_counter}) if pasokara.nico_mylist_counter
        solr_key.merge!({:nico_description => pasokara.nico_description}) if pasokara.nico_description
        solr_key.merge!({:nico_post => pasokara.nico_post}) if pasokara.nico_post
        solr_key.merge!({:duration => pasokara.duration}) if pasokara.duration
        solr_key.merge!({:tag => pasokara.tag_list}) unless pasokara.tag_list.empty?
        solr.add(solr_key)
      end

      solr.commit
      solr.optimize
    end

  end
end

