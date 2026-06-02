require "test_helper"

class PredictionTest < ActiveSupport::TestCase
  setup do
    @tournament = Tournament.create!(name: "Mundial 2026")
    @player = Player.create!(name: "Oscar")
  end

  def future_match
    @tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.from_now)
  end

  def past_match
    @tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.ago)
  end

  test "valid for a match before kickoff" do
    p = Prediction.new(player: @player, match: future_match, home_pred: 2, away_pred: 1)
    assert p.valid?
  end

  test "invalid when match already kicked off" do
    p = Prediction.new(player: @player, match: past_match, home_pred: 2, away_pred: 1)
    assert_not p.valid?
    assert_includes p.errors[:base], "El partido ya comenzó, no se puede pronosticar"
  end

  test "requires non-negative scores" do
    p = Prediction.new(player: @player, match: future_match, home_pred: -1, away_pred: 1)
    assert_not p.valid?
  end

  test "one prediction per player per match" do
    m = future_match
    Prediction.create!(player: @player, match: m, home_pred: 1, away_pred: 0)
    dup = Prediction.new(player: @player, match: m, home_pred: 2, away_pred: 2)
    assert_not dup.valid?
  end
end
