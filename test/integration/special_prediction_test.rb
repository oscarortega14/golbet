require "test_helper"

class SpecialPredictionFlowTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
  end

  test "guest saves a special prediction before kickoff" do
    post session_path, params: { name: "Ana" }
    post special_prediction_path, params: { champion_team_id: @arg.id, top_scorer: "Messi" }
    assert_redirected_to predictions_path
    sp = Player.find_by(name: "Ana").special_predictions.sole
    assert_equal @arg, sp.champion_team
    assert_equal "Messi", sp.top_scorer
  end

  test "predictions page shows the special card" do
    post session_path, params: { name: "Ana" }
    get predictions_path
    assert_response :success
    assert_match "Tu predicción especial", response.body
    assert_select "select[name=champion_team_id]"
  end

  test "cannot save once the tournament has started" do
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.ago, home_label: "C", away_label: "D")
    post session_path, params: { name: "Tarde" }
    post special_prediction_path, params: { champion_team_id: @arg.id }
    assert_equal 0, Player.find_by(name: "Tarde").special_predictions.count
  end
end
