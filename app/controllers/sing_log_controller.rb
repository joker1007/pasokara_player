class SingLogController < ApplicationController
  layout 'pasokara_player'

  def list
    @sing_logs = SingLog.paginate(:all, :order => "created_at desc", :per_page => 50, :page => params[:page])
  end

  def show
    @sing_log = SingLog.find(params[:id])
  end

end
