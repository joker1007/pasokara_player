class ComputerController < ApplicationController
  layout "pasokara_player"

  def list
    @computers = Directory.__find(:all, :select => "computer_name", :group => "computer_name")
  end

  def view_on
    computer = params[:name]
    Directory.online_computers << computer
    PasokaraFile.online_computers << computer
    flash[:notice] = "#{computer}の表示をオンにしました"
    redirect_to root_path
  end

  def view_off
    computer = params[:name]
    Directory.online_computers << computer
    PasokaraFile.online_computers << computer
    flash[:notice] = "#{computer}の表示をオフにしました"
    redirect_to root_path
  end

end
