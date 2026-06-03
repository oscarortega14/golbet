require "test_helper"

class ResultsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", flag: "🇧🇷", group: "A")
    @m = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 1)
  end

  def login(name = "Oscar")
    post session_path, params: { name: name }
  end

  test "shows finished match score and my points (exact = 3)" do
    login
    player = Player.find_by(name: "Oscar")
    Prediction.new(player: player, match: @m, home_pred: 2, away_pred: 1).save!(validate: false)
    get results_path
    assert_response :success
    assert_match "Argentina", response.body
    assert_match "2 - 1", response.body
    assert_match "Brasil", response.body
    assert_match "3 pts", response.body
  end

  test "shows 'Sin pronóstico' when player did not predict" do
    login
    get results_path
    assert_response :success
    assert_match "Sin pronóstico", response.body
  end

  test "shows an empty-state alert when no finished matches" do
    @m.update!(status: "scheduled")
    login
    get results_path
    assert_response :success
    assert_match "Todavía no hay resultados", response.body
  end

  test "requires a player" do
    get results_path
    assert_redirected_to root_path
  end
end
