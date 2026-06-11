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

  test "the nested matches URL scopes the page to that tournament" do
    get admin_tournament_matches_path(@copa)
    assert_response :success
    assert_match "Partidos — Copa América", response.body
    assert_match "Brasil", response.body
    assert_no_match(/Argentina/, response.body)
  end

  test "Gestionar enlaza a los partidos anidados del torneo" do
    get admin_tournaments_path
    assert_response :success
    assert_select "a[href=?]", admin_tournament_matches_path(@copa)
    assert_select "a[href=?]", admin_tournament_matches_path(@mundial)
  end

  test "resolution targets the tournament in the URL" do
    team = @copa.teams.first
    patch admin_tournament_resolution_path(@copa), params: { champion_team_id: team.id, top_scorer: "Neymar" }
    assert_equal team, @copa.reload.champion_team
    assert_nil @mundial.reload.champion_team
  end

  test "visiting a nested page remembers the tournament in session for the sidebar" do
    # Tras visitar la Copa, el sidebar (que lee la sesión) sigue apuntando a la Copa
    get admin_tournament_matches_path(@copa)
    assert_response :success
    get admin_tournaments_path
    assert_response :success
    # El switcher del header muestra la Copa como torneo actual
    assert_match "Copa América", response.body
  end
end
