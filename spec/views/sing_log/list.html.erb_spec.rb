require 'spec_helper'

describe "/sing_log/list" do
  before(:each) do
    render 'sing_log/list'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/sing_log/list])
  end
end
