require "tempfile"
require "test_helper"

class AdminImportFixturesTest < ActionDispatch::IntegrationTest
  setup do
    @mundial = Tournament.create!(name: "Mundial 2026")
    @copa = Tournament.create!(name: "Copa América")
    post admin_login_path, params: { password: "test-admin-pw" }
  end

  TEAMS_CSV = "code,name,flag,group\nBRA,Brasil,🇧🇷,A\nURU,Uruguay,🇺🇾,A\n"
  MATCHES_CSV = "home_code,away_code,group,kickoff_at\nBRA,URU,A,2026-07-01T18:00:00Z\n"

  test "imports teams and matches into the chosen tournament" do
    post import_fixtures_admin_tournament_path(@copa), params: {
      teams_csv: upload_csv(TEAMS_CSV, "teams.csv"),
      matches_csv: upload_csv(MATCHES_CSV, "matches.csv")
    }
    assert_equal 2, @copa.teams.count
    assert @copa.matches.where(stage: "group").exists?
    assert_equal 0, @mundial.teams.count
  end

  test "missing files redirect with an alert" do
    post import_fixtures_admin_tournament_path(@copa)
    assert_redirected_to admin_tournaments_path
    assert_equal 0, @copa.teams.count
  end

  private

  def upload_csv(content, filename)
    file = Tempfile.new(filename)
    file.write(content)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: filename)
  end
end
