require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  test "wrong password is rejected" do
    post admin_login_path, params: { password: "nope" }
    assert_response :unauthorized
    assert_match "Contraseña incorrecta", response.body
  end

  test "correct password reaches matches admin" do
    post admin_login_path, params: { password: "test-admin-pw" }
    assert_redirected_to admin_matches_path
  end

  test "admin pages require login" do
    get admin_matches_path
    assert_redirected_to admin_login_path
  end
end
