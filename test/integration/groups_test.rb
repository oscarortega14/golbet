require "test_helper"

class GroupsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @mex = @t.teams.create!(name: "México", code: "MEX", flag: "🇲🇽", group: "A")
    @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @mex,
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 0)
  end

  test "renders the group table with the leader" do
    post session_path, params: { name: "Viewer" }
    get groups_path
    assert_response :success
    assert_match "Grupo A", response.body
    assert_match "Argentina", response.body
  end

  test "requires a player" do
    get groups_path
    assert_redirected_to root_path
  end
end
