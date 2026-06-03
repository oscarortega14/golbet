require "test_helper"

class SpecialPredictionTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @player = Player.create!(name: "Ana")
  end

  def future_start!
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
  end

  test "valid pick before the tournament starts" do
    future_start!
    sp = SpecialPrediction.new(player: @player, tournament: @t, champion_team: @arg, top_scorer: "Messi")
    assert sp.valid?
  end

  test "one special prediction per (player, tournament)" do
    future_start!
    SpecialPrediction.create!(player: @player, tournament: @t, champion_team: @arg)
    dup = SpecialPrediction.new(player: @player, tournament: @t, champion_team: @arg)
    assert_not dup.valid?
  end

  test "champion must belong to the same tournament" do
    future_start!
    other = Tournament.create!(name: "Otro").teams.create!(name: "X", code: "XXX", group: "A")
    sp = SpecialPrediction.new(player: @player, tournament: @t, champion_team: other)
    assert_not sp.valid?
  end

  test "blocked once the tournament has started" do
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.ago, home_label: "A", away_label: "B")
    sp = SpecialPrediction.new(player: @player, tournament: @t, champion_team: @arg)
    assert_not sp.valid?
    assert_includes sp.errors[:base], "El torneo ya comenzó, no se puede cambiar tu predicción especial"
  end

  test "normalize strips accents, case and extra spaces" do
    assert_equal "messi", SpecialPrediction.normalize("  MÉSSI ")
    assert_equal "kylian mbappe", SpecialPrediction.normalize("Kylian   Mbappé")
  end
end
