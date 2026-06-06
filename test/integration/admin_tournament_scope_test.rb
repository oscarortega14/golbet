require "test_helper"

class AdminTournamentScopeTest < ActionDispatch::IntegrationTest
  setup do
    @mundial = Tournament.create!(name: "Mundial 2026")     # activo
    @copa = Tournament.create!(name: "Copa América")
    @mundial.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @copa.teams.create!(name: "Brasil", code: "BRA", group: "A")
    @mundial.matches.create!(stage: "group", group: "A", home_label: "A1", away_label: "A2", kickoff_at: 1.hour.ago)
    brasil = @copa.teams.find_by!(name: "Brasil")
    @copa.matches.create!(stage: "group", group: "A", home_label: "B1", away_label: "B2", kickoff_at: 1.hour.ago, home_team: brasil)
    post admin_login_path, params: { password: "test-admin-pw" }
  end

  test "admin matches defaults to the active tournament" do
    get admin_matches_path
    assert_response :success
    assert_match "Mundial 2026", response.body
  end

  test "selecting a tournament scopes the admin matches page to it" do
    post select_admin_tournament_path(@copa)
    get admin_matches_path
    assert_response :success
    assert_match "Copa América", response.body
    assert_match "Brasil", response.body
    assert_no_match(/Argentina/, response.body)
  end

  test "resolution targets the selected tournament" do
    post select_admin_tournament_path(@copa)
    team = @copa.teams.first
    patch admin_resolution_path, params: { champion_team_id: team.id, top_scorer: "Neymar" }
    assert_equal team, @copa.reload.champion_team
    assert_nil @mundial.reload.champion_team
  end

  test "the admin_tournament query param persists the selection to the session" do
    # Selecciona la Copa vía el query param del dropdown (GET), no la acción select
    get admin_matches_path(admin_tournament: @copa.id)
    assert_response :success
    assert_match "Copa América", response.body
    assert_match "Brasil", response.body

    # La selección persiste en la sesión: una visita posterior SIN el param sigue mostrando la Copa
    get admin_matches_path
    assert_response :success
    assert_match "Partidos — Copa América", response.body
    assert_no_match(/Partidos — Mundial 2026/, response.body)
  end
end
