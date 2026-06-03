require "test_helper"

class FixtureImporterTest < ActiveSupport::TestCase
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  TEAMS_CSV = <<~CSV
    name,code,flag,group
    Argentina,ARG,🇦🇷,A
    México,MEX,🇲🇽,A
  CSV

  MATCHES_CSV = <<~CSV
    group,home_code,away_code,kickoff_at
    A,ARG,MEX,2026-06-11 19:00
  CSV

  test "imports teams and group matches" do
    result = FixtureImporter.new(@t, teams_csv: TEAMS_CSV, matches_csv: MATCHES_CSV).import
    assert result.success?, result.errors.inspect
    assert_equal 2, @t.teams.count
    m = @t.matches.sole
    assert_equal "group", m.stage
    assert_equal "A", m.group
    assert_equal "ARG", m.home_team.code
    assert_equal "MEX", m.away_team.code
  end

  test "is idempotent" do
    importer = -> { FixtureImporter.new(@t, teams_csv: TEAMS_CSV, matches_csv: MATCHES_CSV).import }
    importer.call
    importer.call
    assert_equal 2, @t.teams.count
    assert_equal 1, @t.matches.count
  end

  test "reports an unknown team code without raising" do
    bad = "group,home_code,away_code,kickoff_at\nA,ZZZ,MEX,2026-06-11 19:00\n"
    result = FixtureImporter.new(@t, teams_csv: TEAMS_CSV, matches_csv: bad).import
    assert_not result.success?
    assert(result.errors.any? { |e| e.include?("ZZZ") })
  end
end
