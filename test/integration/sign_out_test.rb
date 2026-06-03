require "test_helper"

class SignOutTest < ActionDispatch::IntegrationTest
  test "sign out clears the player and returns to root" do
    post session_path, params: { name: "Oscar" }
    assert_response :redirect
    delete session_path
    assert_redirected_to root_path
    get predictions_path
    assert_redirected_to root_path
  end
end
