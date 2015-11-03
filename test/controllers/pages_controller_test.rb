require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get installing" do
    get :installing
    assert_response :success
  end

end
