# frozen_string_literal: true

require "test_helper"

class AdminResolutionTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
  end

  test "admin sets the champion and top scorer" do
    post admin_login_path, params: { password: "test-admin-pw" }
    patch admin_tournament_resolution_path(@t), params: { champion_team_id: @arg.id, top_scorer: "Messi" }
    assert_redirected_to admin_tournament_resolution_path(@t)
    @t.reload
    assert_equal @arg, @t.champion_team
    assert_equal "Messi", @t.top_scorer
  end

  test "resolution requires admin" do
    get admin_tournament_resolution_path(@t)
    assert_redirected_to admin_login_path
  end
end
