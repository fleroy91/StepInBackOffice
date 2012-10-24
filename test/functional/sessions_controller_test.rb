require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "devrait avoir le bon titre" do
      get :new
      response.should have_selector("titre", :content => "Login")
  end

end
