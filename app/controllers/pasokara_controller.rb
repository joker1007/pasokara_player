class PasokaraController < ApplicationController
  def queue
    @pasokara = PasokaraFile.find(params[:id])
    QueuedFile.enq @pasokara
    flash[:notice] = "#{@pasokara.name} の予約が完了しました"
    redirect_to :controller => "dir", :action => "show", :id => @pasokara.directory.id
  end

  def queue_list
    @queue_list = QueuedFile.find(:all, :order => "created_at")
    if request.xhr?
      render :update do |page|
        page.replace_html("queue_table", :partial => "queue_list", :object => @queue_list)
      end
    end
  end

  def search
    @query = params[:query]
    @pasokaras = PasokaraFile.paginate(:all, :conditions => ["fullpath LIKE ?", "%#{@query}%"], :page => params[:page], :per_page => 50, :order => "name")
  end
end
