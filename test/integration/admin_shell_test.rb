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

  test "results page mounts the shell with results active" do
    get admin_results_path
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_select "a[href=?][aria-current=page]", admin_results_path
  end

  test "resolution page mounts the shell with resolution active" do
    get admin_resolution_path
    assert_response :success
    assert_select "a[href=?][aria-current=page]", admin_resolution_path
  end

  test "tournaments page mounts the shell with tournaments active" do
    get admin_tournaments_path
    assert_response :success
    assert_select "a[href=?][aria-current=page]", admin_tournaments_path
  end

  test "matches edit form mounts the shell with matches active" do
    m = @tournament.matches.create!(stage: "group", group: "A", kickoff_at: 1.day.from_now,
                                    home_label: "L1", away_label: "L2")
    get edit_admin_match_path(m)
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_select "a[href=?][aria-current=page]", admin_matches_path
  end

  test "matches index paginates and preserves no filters by default" do
    25.times do |i|
      @tournament.matches.create!(stage: "group", group: "A", kickoff_at: (i + 1).days.from_now,
                                  home_label: "L#{i}a", away_label: "L#{i}b")
    end
    get admin_matches_path
    assert_response :success
    assert_select "nav[aria-label=?] a[href*=?]", "pagination", "page=2"
    get admin_matches_path(page: 2)
    assert_response :success
  end

  test "login page does NOT mount the sidebar shell" do
    delete admin_logout_path
    get admin_login_path
    assert_response :success
    assert_no_match "wabi--sidebar", response.body
  end
end
