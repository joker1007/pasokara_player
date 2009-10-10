class FavoriteController < ApplicationController
  before_filter :top_tag_load
  layout "pasokara_player"

  def add
    @pasokara = PasokaraFile.find(params[:id])
    unless @user.pasokara_files.include? @pasokara
      if @user.pasokara_files << @pasokara
        message = "#{@pasokara.name}が#{@user.name}のお気に入りに追加されました"
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
    Favorite.find_by_user_id_and_pasokara_file_id(session[:current_user], params[:id]).destroy
    message = "#{@pasokara.name}が#{@user.name}のお気に入りから削除されました"

    if request.xhr?
      render :update do |page|
        page.alert(message)
      end
    else
      flash[:notice] = message
      redirect_to :action => "list"
    end
  end

  def list
    @pasokaras = @user.pasokara_files.paginate(:page => params[:page], :per_page => 50)
  end
end
