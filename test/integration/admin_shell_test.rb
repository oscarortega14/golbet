require "test_helper"

class AdminShellTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = Tournament.first || Tournament.create!(name: "Mundial 2026")
    @tournament.update!(active: true)
    post admin_login_path, params: { password: "test-admin-pw" }
  end

  test "admin matches page renders the sidebar shell" do
    get admin_matches_path
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_match "golbet-admin-sidebar", response.body
    assert_select "a[href=?]", admin_tournaments_path
    assert_select "a[href=?]", admin_matches_path
    assert_select "a[href=?]", admin_results_path
    assert_select "a[href=?]", admin_resolution_path
    assert_select "a[href=?][aria-current=page]", admin_matches_path
    assert_match "Partidos", response.body
    assert_select "form[action=?]", admin_logout_path
  end
end
