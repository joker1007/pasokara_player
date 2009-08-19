class QueueController < ApplicationController
  layout "dir"

  def list
    @queue_list = QueuedFile.find(:all, :order => "created_at")
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
