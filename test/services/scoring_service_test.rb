require "test_helper"

class ScoringServiceTest < ActiveSupport::TestCase
  setup do
    @tournament = Tournament.create!(name: "Mundial 2026")
    @player = Player.create!(name: "Oscar")
  end

  def finished_match(hs, as)
    @tournament.matches.create!(home_team: "ARG", away_team: "BRA",
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
    m = @tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.from_now)
    assert_equal 0, ScoringService.points_for(predict(m, 2, 1), m)
  end
end
