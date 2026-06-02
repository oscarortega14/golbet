require "test_helper"

class MatchTest < ActiveSupport::TestCase
  def tournament
    @tournament ||= Tournament.create!(name: "Mundial 2026")
  end

  test "defaults to scheduled status" do
    m = tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.day.from_now)
    assert_equal "scheduled", m.status
  end

  test "finished? reflects status" do
    m = tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.day.from_now, status: "finished")
    assert m.finished?
  end

  test "locked? is true once kickoff has passed" do
    past = tournament.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.ago)
    future = tournament.matches.create!(home_team: "URU", away_team: "CHI", kickoff_at: 1.hour.from_now)
    assert past.locked?
    assert_not future.locked?
  end
end
