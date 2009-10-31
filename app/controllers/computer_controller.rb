class ComputerController < ApplicationController
  layout "pasokara_player"

  def list
    @computers = Computer.find(:all)
  end

  def edit
    @computer = Computer.find(params[:id])
  end

  def update
    @computer = Computer.find(params[:id])
    if @computer.update_attributes(params[:computer])
      flash[:notice] = "#{@computer.name}が変更されました"
      redirect_to :action => "list"
    else
      render :action => "edit"
    end
  end

  def view_on
    @computer = Computer.find(params[:id])
    @computer.online = true
    @computer.save
    flash[:notice] = "#{@computer.name}の表示をオンにしました"
    redirect_to root_path
  end

  def view_off
    @computer = Computer.find(params[:id])
    @computer.online = false
    @computer.save
    flash[:notice] = "#{@computer.name}の表示をオフにしました"
    redirect_to root_path
  end

end
