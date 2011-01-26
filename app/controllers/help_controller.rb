class HelpController < ApplicationController
  def usage
    render :layout => "pasokara_player_notags"
  end
end
