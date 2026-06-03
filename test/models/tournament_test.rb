require "test_helper"

class TournamentTest < ActiveSupport::TestCase
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  test "not started with no matches" do
    assert_not @t.started?
  end

  test "not started when earliest kickoff is in the future" do
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    assert_not @t.started?
  end

  test "started once the earliest kickoff has passed" do
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.ago,      home_label: "C", away_label: "D")
    assert @t.started?
  end

  test "can hold a champion team and top scorer" do
    team = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @t.update!(champion_team: team, top_scorer: "Messi")
    assert_equal team, @t.reload.champion_team
    assert_equal "Messi", @t.top_scorer
  end
end
