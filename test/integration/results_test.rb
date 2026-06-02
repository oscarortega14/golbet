require "test_helper"

class ResultsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @m = @t.matches.create!(home_team: "ARG", away_team: "BRA",
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
    assert_match "ARG 2 - 1 BRA", response.body
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
