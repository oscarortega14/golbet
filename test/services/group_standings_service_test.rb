require "test_helper"

class GroupStandingsServiceTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @mex = @t.teams.create!(name: "México", code: "MEX", group: "A")
    @pol = @t.teams.create!(name: "Polonia", code: "POL", group: "A")
  end

  def finished(home, away, hs, as)
    @t.matches.create!(stage: "group", group: "A", home_team: home, away_team: away,
      kickoff_at: 2.hours.ago, status: "finished", home_score: hs, away_score: as)
  end

  test "computes points, GD, GF and orders them" do
    finished(@arg, @mex, 2, 0) # ARG win
    finished(@mex, @pol, 1, 1) # draw
    rows = GroupStandingsService.for(@t)["A"]
    arg = rows.find { |r| r[:team] == @arg }
    assert_equal({ pj: 1, g: 1, e: 0, p: 0, gf: 2, gc: 0, dg: 2, pts: 3 },
                 arg.slice(:pj, :g, :e, :p, :gf, :gc, :dg, :pts))
    assert_equal @arg, rows.first[:team]
    assert_equal [@arg, @pol, @mex], rows.map { |r| r[:team] }
  end

  test "includes teams with no games played as zeros" do
    rows = GroupStandingsService.for(@t)["A"]
    assert_equal 3, rows.size
    assert(rows.all? { |r| r[:pj].zero? && r[:pts].zero? })
  end
end
