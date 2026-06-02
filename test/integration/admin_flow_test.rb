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

  test "admin creates a match" do
    post admin_login_path, params: { password: "test-admin-pw" }
    assert_difference -> { Match.count }, 1 do
      post admin_matches_path, params: { match: {
        home_team: "ARG", away_team: "BRA",
        kickoff_at: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
      } }
    end
    assert_redirected_to admin_matches_path
    follow_redirect!
    assert_match "ARG vs BRA", response.body
  end

  test "new match form renders fields" do
    post admin_login_path, params: { password: "test-admin-pw" }
    get new_admin_match_path
    assert_response :success
    assert_select "input[name=?]", "match[home_team]"
    assert_select "input[name=?]", "match[kickoff_at]"
  end
end
