class HelpController < ApplicationController
  layout "pasokara_player"

  before_filter :no_tag_load

  def usage
  end
end
