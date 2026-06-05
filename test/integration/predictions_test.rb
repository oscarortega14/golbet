require "test_helper"

class PredictionsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", flag: "🇧🇷", group: "A")
    @uru = @t.teams.create!(name: "Uruguay", code: "URU", flag: "🇺🇾", group: "B")
    @chi = @t.teams.create!(name: "Chile", code: "CHI", flag: "🇨🇱", group: "B")
    @pool = Pool.create!(tournament: @t, name: "General", public: true)
  end

  def login(name)
    post session_path, params: { name: name }
  end

  test "index renders an upcoming match with score inputs" do
    @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    login "Oscar"
    get predictions_path
    assert_response :success
    assert_match "Argentina", response.body
    assert_match "Brasil", response.body
    assert_select "input[name=home_pred]"
    assert_select "input[name=away_pred]"
  end

  test "player saves a prediction for an upcoming match" do
    m = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    login "Oscar"
    player = Player.find_by(name: "Oscar")
    post predictions_path, params: { match_id: m.id, home_pred: 2, away_pred: 1 }
    assert_response :redirect
    pred = player.predictions.first
    assert_equal [2, 1], [pred.home_pred, pred.away_pred]
  end

  test "saving again updates the same prediction (upsert)" do
    m = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    login "Oscar"
    player = Player.find_by(name: "Oscar")
    post predictions_path, params: { match_id: m.id, home_pred: 2, away_pred: 1 }
    post predictions_path, params: { match_id: m.id, home_pred: 3, away_pred: 0 }
    assert_equal 1, player.predictions.count
    assert_equal [3, 0], player.predictions.first.then { |p| [p.home_pred, p.away_pred] }
  end

  test "locked match shows Cerrado and no inputs" do
    @t.matches.create!(stage: "group", group: "B", home_team: @uru, away_team: @chi, kickoff_at: 1.hour.ago)
    login "Ana"
    get predictions_path
    assert_response :success
    assert_match "Cerrado", response.body
    assert_select "input[name=home_pred]", false
  end

  test "TBD knockout match shows 'Por definir' and no score inputs" do
    @t.matches.create!(stage: "round_of_32", slot: 1, kickoff_at: 1.day.from_now,
                       home_label: "R32 #1 — Local", away_label: "R32 #1 — Visitante")
    post session_path, params: { name: "Ana" }
    get predictions_path
    assert_response :success
    assert_match "Por definir", response.body
  end

  test "requires a player (redirects to root when not logged in)" do
    get predictions_path
    assert_redirected_to root_path
  end
end
