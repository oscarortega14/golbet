require "test_helper"

class ScoringServiceTest < ActiveSupport::TestCase
  setup do
    @tournament = Tournament.create!(name: "Mundial 2026")
    @arg = @tournament.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @tournament.teams.create!(name: "Brasil", code: "BRA", group: "B")
    @player = Player.create!(name: "Oscar")
  end

  def finished_match(hs, as)
    @tournament.matches.create!(home_team: @arg, away_team: @bra, stage: "group",
      kickoff_at: 2.hours.ago, status: "finished", home_score: hs, away_score: as)
  end

  def predict(match, hp, ap)
    Prediction.new(player: @player, match: match, home_pred: hp, away_pred: ap)
  end

  test "exact score gives 3 points" do
    m = finished_match(2, 1)
    assert_equal 3, ScoringService.points_for(predict(m, 2, 1), m)
  end

  test "correct home win but wrong score gives 1 point" do
    m = finished_match(2, 1)
    assert_equal 1, ScoringService.points_for(predict(m, 3, 0), m)
  end

  test "correct draw but wrong score gives 1 point" do
    m = finished_match(1, 1)
    assert_equal 1, ScoringService.points_for(predict(m, 2, 2), m)
  end

  test "wrong outcome gives 0 points" do
    m = finished_match(2, 1)
    assert_equal 0, ScoringService.points_for(predict(m, 0, 2), m)
  end

  test "unfinished match gives 0 points" do
    m = @tournament.matches.create!(home_team: @arg, away_team: @bra, stage: "group", kickoff_at: 1.hour.from_now)
    assert_equal 0, ScoringService.points_for(predict(m, 2, 1), m)
  end

  test "standings ranks players by total points then name" do
    m1 = finished_match(2, 1)
    m2 = finished_match(0, 0)
    ana = Player.create!(name: "Ana")
    beto = Player.create!(name: "Beto")
    # Ana: exact on m1 (3) + exact draw on m2 (3) = 6
    Prediction.new(player: ana, match: m1, home_pred: 2, away_pred: 1).save!(validate: false)
    Prediction.new(player: ana, match: m2, home_pred: 0, away_pred: 0).save!(validate: false)
    # Beto: outcome on m1 (1) + miss on m2 (0) = 1
    Prediction.new(player: beto, match: m1, home_pred: 1, away_pred: 0).save!(validate: false)
    Prediction.new(player: beto, match: m2, home_pred: 1, away_pred: 0).save!(validate: false)

    rows = ScoringService.standings(@tournament)
    assert_equal ["Ana", "Beto"], rows.map { |r| r[:player].name }
    assert_equal [6, 1], rows.map { |r| r[:points] }
  end

  test "standings excludes players with no predictions on finished matches" do
    m = finished_match(1, 0)
    Player.create!(name: "NoPreds")
    scorer = Player.create!(name: "Scorer")
    Prediction.new(player: scorer, match: m, home_pred: 1, away_pred: 0).save!(validate: false)
    names = ScoringService.standings(@tournament).map { |r| r[:player].name }
    assert_includes names, "Scorer"
    assert_not_includes names, "NoPreds"
  end

  test "match_points multiplies the base by the stage factor" do
    final = @tournament.matches.create!(stage: "final", home_team: @arg, away_team: @bra,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 1)
    exact = Prediction.new(player: @player, match: final, home_pred: 2, away_pred: 1)
    assert_equal 15, ScoringService.match_points(exact, final)   # 3 (exact) * 5 (final)

    qf = @tournament.matches.create!(stage: "quarter_final", home_team: @arg, away_team: @bra,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 1)
    outcome = Prediction.new(player: @player, match: qf, home_pred: 3, away_pred: 0)
    assert_equal 3, ScoringService.match_points(outcome, qf)     # 1 (outcome) * 3 (QF)
  end

  test "group stage keeps the base (x1)" do
    g = @tournament.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 1, away_score: 0)
    exact = Prediction.new(player: @player, match: g, home_pred: 1, away_pred: 0)
    assert_equal 3, ScoringService.match_points(exact, g)
  end

  test "special_points awards champion and top-scorer bonuses when resolved" do
    sp = SpecialPrediction.new(champion_team: @arg, top_scorer: "Messi")
    @tournament.update!(champion_team: @arg, top_scorer: "MÉSSI") # normalized match
    assert_equal 25, ScoringService.special_points(sp, @tournament) # 15 + 10
  end

  test "special_points gives nothing before resolution or on a miss" do
    sp = SpecialPrediction.new(champion_team: @bra, top_scorer: "Otro")
    assert_equal 0, ScoringService.special_points(sp, @tournament)         # unresolved
    @tournament.update!(champion_team: @arg, top_scorer: "Messi")
    assert_equal 0, ScoringService.special_points(sp, @tournament)         # both wrong
  end

  test "standings adds the special bonus to a player's match points" do
    g = @tournament.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 1, away_score: 0)
    Prediction.new(player: @player, match: g, home_pred: 1, away_pred: 0).save!(validate: false) # 3
    # seed a special prediction past the start-lock (lock is a user-flow guard, not scoring):
    SpecialPrediction.new(player: @player, tournament: @tournament, champion_team: @arg).save!(validate: false)
    @tournament.update!(champion_team: @arg) # +15
    row = ScoringService.standings(@tournament).find { |r| r[:player] == @player }
    assert_equal 18, row[:points]   # 3 + 15
  end
end
