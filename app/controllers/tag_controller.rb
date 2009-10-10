# _*_ coding: utf-8 _*_
class TagController < ApplicationController
  layout "pasokara_player"

  def list
    options = {:order => "count desc, tags.name asc"}
    @tags = PasokaraFile.tag_counts(options).paginate(:page => params[:page], :per_page => 50)
  end
end
