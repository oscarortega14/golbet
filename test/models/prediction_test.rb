require "test_helper"

class PredictionTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", group: "A")
    @player = Player.create!(name: "Oscar")
    @pool = Pool.create!(tournament: @t, name: "General", public: true)
  end

  def future_match
    @t.matches.create!(home_team: @arg, away_team: @bra, kickoff_at: 1.hour.from_now)
  end

  test "valid before kickoff with both teams" do
    p = Prediction.new(player: @player, pool: @pool, match: future_match, home_pred: 2, away_pred: 1)
    assert p.valid?
  end

  test "invalid after kickoff" do
    m = @t.matches.create!(home_team: @arg, away_team: @bra, kickoff_at: 1.hour.ago)
    p = Prediction.new(player: @player, pool: @pool, match: m, home_pred: 2, away_pred: 1)
    assert_not p.valid?
    assert_includes p.errors[:base], "El partido ya comenzó, no se puede pronosticar"
  end

  test "invalid when match has no teams yet (TBD)" do
    tbd = @t.matches.create!(stage: "round_of_32", kickoff_at: 1.day.from_now,
                             home_label: "Cruce R32 #1", away_label: "Cruce R32 #2")
    p = Prediction.new(player: @player, pool: @pool, match: tbd, home_pred: 1, away_pred: 0)
    assert_not p.valid?
    assert_includes p.errors[:base], "Este partido aún no tiene equipos definidos"
  end

  test "requires non-negative scores" do
    p = Prediction.new(player: @player, pool: @pool, match: future_match, home_pred: -1, away_pred: 1)
    assert_not p.valid?
  end

  test "one prediction per player per pool per match" do
    m = future_match
    Prediction.create!(player: @player, pool: @pool, match: m, home_pred: 1, away_pred: 0)
    assert_not Prediction.new(player: @player, pool: @pool, match: m, home_pred: 2, away_pred: 2).valid?
  end

  test "same match allowed in a different pool" do
    other = Pool.create!(tournament: @t, name: "Otra")
    m = future_match
    Prediction.create!(player: @player, pool: @pool, match: m, home_pred: 1, away_pred: 0)
    assert Prediction.new(player: @player, pool: other, match: m, home_pred: 2, away_pred: 2).valid?
  end
end
