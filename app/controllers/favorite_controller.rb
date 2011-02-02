# _*_ coding: utf-8 _*_
class FavoriteController < ApplicationController
  before_filter :top_tag_load
  before_filter :login_required
  layout "pasokara_player"

  def add
    @pasokara = PasokaraFile.find(params[:id])
    unless current_user.pasokara_files.include? @pasokara
      if current_user.pasokara_files << @pasokara
        message = "#{@pasokara.name}が#{current_user.name}のお気に入りに追加されました"
      else
        message = "お気に入りの追加に失敗しました"
      end
    else
      message = "既に登録済みです"
    end

    if request.xhr?
      render :update do |page|
        page.alert(message)
      end
    else
      flash[:notice] = message
      redirect_to root_path
    end
  end

  def remove
    @pasokara = PasokaraFile.find(params[:id])
    Favorite.find_by_user_id_and_pasokara_file_id(current_user.id, params[:id]).destroy
    message = "#{@pasokara.name}が#{current_user.name}のお気に入りから削除されました"

    if request.xhr?
      render :update do |page|
        page.alert(message)
        page.visual_effect :fade, @pasokara.html_id
      end
    else
      flash[:notice] = message
      redirect_to :action => "list"
    end
  end

  def list
    unless current_user
      redirect_to :controller => "user", :action => "switch" and return
    else
      options = {:page => params[:page], :per_page => 50}
      order = order_options
      options.merge!(order)

      @pasokaras = current_user.pasokara_files.paginate(options)
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @pasokaras.to_xml }
      format.json { render :json => @pasokaras.to_json }
    end
  end
end
