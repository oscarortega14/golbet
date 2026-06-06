require "test_helper"

class MultiTournamentTest < ActionDispatch::IntegrationTest
  setup do
    @mundial = Tournament.create!(name: "Mundial 2026")        # activo (primero)
    @copa = Tournament.create!(name: "Copa América")           # no activo
    @arg = @mundial.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @mex = @mundial.teams.create!(name: "México", code: "MEX", flag: "🇲🇽", group: "A")
    @mundial.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @mex,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 0)
    @bra = @copa.teams.create!(name: "Brasil", code: "BRA", flag: "🇧🇷", group: "A")
    @uru = @copa.teams.create!(name: "Uruguay", code: "URU", flag: "🇺🇾", group: "A")
    @copa.matches.create!(stage: "group", group: "A", home_team: @bra, away_team: @uru,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 1, away_score: 1)
  end

  test "auto-join is the active tournament's General" do
    post session_path, params: { name: "Ana" }
    get groups_path
    assert_response :success
    assert_match "Argentina", response.body   # del Mundial (activo)
    assert_no_match(/Brasil/, response.body)   # no el de la Copa
  end

  test "switching to a Copa pool shows Copa data on tournament pages" do
    post session_path, params: { name: "Ana" }          # SessionsController finds/creates by name
    copa_general = Pool.create!(tournament: @copa, name: "General", public: true)
    player = Player.find_by(name: "Ana")
    Membership.create!(player: player, pool: copa_general)
    post select_pool_path(copa_general)
    get groups_path
    assert_response :success
    assert_match "Brasil", response.body       # del torneo de la polla actual
    assert_no_match(/Argentina/, response.body)
  end
end
