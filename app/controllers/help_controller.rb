class HelpController < ApplicationController
  layout "pasokara_player"

  def usage
    @notag_list = true
  end
end
