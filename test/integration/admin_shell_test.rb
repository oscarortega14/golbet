require "test_helper"

class AdminShellTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = Tournament.first || Tournament.create!(name: "Mundial 2026")
    @tournament.update!(active: true)
    post admin_login_path, params: { password: "test-admin-pw" }
  end

  test "tournaments fixtures uploader uses Wabi FileUpload with submittable inputs" do
    get admin_tournaments_path
    assert_response :success
    # El componente FileUpload monta el controller y un dropzone
    assert_match "wabi--file-upload", response.body
    # Los inputs ocultos conservan los names que espera el controller de import
    assert_select "input[type=file][name=?]", "teams_csv"
    assert_select "input[type=file][name=?]", "matches_csv"
  end

  test "admin matches page renders the sidebar shell with nested nav" do
    get admin_tournament_matches_path(@tournament)
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_match "golbet-admin-sidebar", response.body
    assert_select "a[href=?]", admin_tournaments_path
    assert_select "a[href=?]", admin_tournament_matches_path(@tournament)
    assert_select "a[href=?]", admin_tournament_results_path(@tournament)
    assert_select "a[href=?]", admin_tournament_resolution_path(@tournament)
    assert_select "a[href=?][aria-current=page]", admin_tournament_matches_path(@tournament)
    assert_match "Partidos", response.body
    assert_select "form[action=?]", admin_logout_path
  end

  test "breadcrumb shows Admin / tournament / section on a nested page" do
    get admin_tournament_matches_path(@tournament)
    assert_response :success
    assert_match "Mundial 2026", response.body
    assert_select "nav[aria-label=?]", "breadcrumb"
  end

  test "results page mounts the shell with results active" do
    get admin_tournament_results_path(@tournament)
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_select "a[href=?][aria-current=page]", admin_tournament_results_path(@tournament)
  end

  test "resolution page mounts the shell with resolution active" do
    get admin_tournament_resolution_path(@tournament)
    assert_response :success
    assert_select "a[href=?][aria-current=page]", admin_tournament_resolution_path(@tournament)
  end

  test "tournaments page mounts the shell with tournaments active" do
    get admin_tournaments_path
    assert_response :success
    assert_select "a[href=?][aria-current=page]", admin_tournaments_path
  end

  test "matches edit form mounts the shell with matches active" do
    m = @tournament.matches.create!(stage: "group", group: "A", kickoff_at: 1.day.from_now,
                                    home_label: "L1", away_label: "L2")
    get edit_admin_tournament_match_path(@tournament, m)
    assert_response :success
    assert_match "wabi--sidebar", response.body
    assert_select "a[href=?][aria-current=page]", admin_tournament_matches_path(@tournament)
  end

  test "matches index paginates and preserves no filters by default" do
    25.times do |i|
      @tournament.matches.create!(stage: "group", group: "A", kickoff_at: (i + 1).days.from_now,
                                  home_label: "L#{i}a", away_label: "L#{i}b")
    end
    get admin_tournament_matches_path(@tournament)
    assert_response :success
    assert_select "nav[aria-label=?] a[href*=?]", "pagination", "page=2"
    get admin_tournament_matches_path(@tournament, page: 2)
    assert_response :success
  end

  test "matches list wires tooltips on the edit action" do
    @tournament.matches.create!(stage: "group", group: "A", kickoff_at: 1.day.from_now,
                                home_label: "L1", away_label: "L2")
    get admin_tournament_matches_path(@tournament)
    assert_response :success
    assert_match "wabi--tooltip", response.body
    assert_match "Editar equipos y horario", response.body
  end

  test "matches pagination preserves stage and group filters in page links" do
    25.times do |i|
      @tournament.matches.create!(stage: "group", group: "A", kickoff_at: (i + 1).days.from_now,
                                  home_label: "G#{i}a", away_label: "G#{i}b")
    end
    get admin_tournament_matches_path(@tournament, stage: "group", group: "A")
    assert_response :success
    # The page-2 link must carry the active filters forward
    assert_select "nav[aria-label=?] a[href*=?]", "pagination", "stage=group"
    assert_select "nav[aria-label=?] a[href*=?]", "pagination", "group=A"
    assert_select "nav[aria-label=?] a[href*=?]", "pagination", "page=2"
  end

  test "login page does NOT mount the sidebar shell" do
    delete admin_logout_path
    get admin_login_path
    assert_response :success
    assert_no_match "wabi--sidebar", response.body
  end
end
