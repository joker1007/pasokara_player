# _*_ coding: utf-8 _*_
class QueueController < ApplicationController
  layout 'pasokara_player'


  def list
    @queue_list = QueuedFile.find(:all, :order => "created_at", :include => :pasokara_file)
    if request.xhr?
      render :update do |page|
        page.replace_html("queue_table", :partial => "list", :object => @queue_list)
      end
    end
  end

  def remove
    @queue = QueuedFile.find(params[:id])
    @queue.destroy
    flash[:notice] = "#{@queue.name}の予約が取り消されました"
    redirect_to :action => 'list'
  end

end
