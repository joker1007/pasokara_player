require 'spec_helper'

describe "/sing_log/list" do
  fixtures :sing_logs, :users, :pasokara_files

  before(:each) do
    assigns[:sing_logs] = SingLog.paginate(:all, :order => "created_at desc", :per_page => 50, :page => params[:page])
    render 'sing_log/list'
  end

  #Delete this example and add some real ones or delete this file
  it "2つのログがリストに表示される" do
    response.should have_tag('li')
    response.should have_tag('li')
    response.should have_tag('li')
  end
end
