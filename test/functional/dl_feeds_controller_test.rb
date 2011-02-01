require 'test_helper'

class DlFeedsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dl_feeds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dl_feed" do
    assert_difference('DlFeed.count') do
      post :create, :dl_feed => { }
    end

    assert_redirected_to dl_feed_path(assigns(:dl_feed))
  end

  test "should show dl_feed" do
    get :show, :id => dl_feeds(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => dl_feeds(:one).to_param
    assert_response :success
  end

  test "should update dl_feed" do
    put :update, :id => dl_feeds(:one).to_param, :dl_feed => { }
    assert_redirected_to dl_feed_path(assigns(:dl_feed))
  end

  test "should destroy dl_feed" do
    assert_difference('DlFeed.count', -1) do
      delete :destroy, :id => dl_feeds(:one).to_param
    end

    assert_redirected_to dl_feeds_path
  end
end
