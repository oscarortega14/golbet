require "test_helper"

class MatchTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", group: "A")
  end

  def build_match(**attrs)
    @t.matches.new({ home_team: @arg, away_team: @bra, kickoff_at: 1.day.from_now }.merge(attrs))
  end

  test "defaults to scheduled group match" do
    m = build_match
    assert m.save
    assert_equal "scheduled", m.status
    assert_equal "group", m.stage
  end

  test "finished? reflects status" do
    assert build_match(status: "finished").finished?
  end

  test "locked? true once kickoff passed" do
    assert build_match(kickoff_at: 1.hour.ago).locked?
    assert_not build_match(kickoff_at: 1.hour.from_now).locked?
  end

  test "teams_set?/tbd?/predictable?" do
    ready = build_match(kickoff_at: 1.hour.from_now)
    assert ready.teams_set?
    assert ready.predictable?
    assert_not ready.tbd?

    tbd = @t.matches.new(stage: "round_of_32", kickoff_at: 1.day.from_now,
                         home_label: "Cruce R32 #1", away_label: "Cruce R32 #2")
    assert tbd.tbd?
    assert_not tbd.predictable?
    assert_equal "Cruce R32 #1", tbd.display_home
  end

  test "rejects an invalid stage" do
    m = build_match(stage: "quarterfinals")
    assert_not m.valid?
  end
end
