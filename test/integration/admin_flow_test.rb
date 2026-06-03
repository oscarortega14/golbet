require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = Tournament.first || Tournament.create!(name: "Mundial 2026")
    @arg = @tournament.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @tournament.teams.create!(name: "Brasil", code: "BRA", group: "B")
  end

  test "wrong password is rejected" do
    post admin_login_path, params: { password: "nope" }
    assert_response :unauthorized
    assert_match "Contraseña incorrecta", response.body
  end

  test "correct password reaches matches admin" do
    post admin_login_path, params: { password: "test-admin-pw" }
    assert_redirected_to admin_matches_path
  end

  test "admin pages require login" do
    get admin_matches_path
    assert_redirected_to admin_login_path
  end

  test "admin assigns teams to a TBD knockout match" do
    ko = @tournament.matches.create!(stage: "round_of_32", slot: 1, kickoff_at: 1.day.from_now,
                                     home_label: "R32 #1 — Local", away_label: "R32 #1 — Visitante")
    post admin_login_path, params: { password: "test-admin-pw" }
    patch admin_match_path(ko), params: { match: { home_team_id: @arg.id, away_team_id: @bra.id } }
    ko.reload
    assert ko.teams_set?
    assert_equal "ARG", ko.home_team.code
  end

  test "admin enters a result, match becomes finished and scoring reflects it" do
    m = @tournament.matches.create!(home_team: @arg, away_team: @bra, stage: "group", group: "A", kickoff_at: 1.hour.ago)
    ana = Player.create!(name: "Ana")
    Prediction.new(player: ana, match: m, home_pred: 2, away_pred: 1).save!(validate: false)

    post admin_login_path, params: { password: "test-admin-pw" }
    patch admin_result_path(m), params: { home_score: 2, away_score: 1 }
    assert_redirected_to admin_results_path

    m.reload
    assert m.finished?
    assert_equal 3, ScoringService.points_for(ana.predictions.first, m)
  end

  test "results admin page lists matches" do
    post admin_login_path, params: { password: "test-admin-pw" }
    get admin_results_path
    assert_response :success
  end

  test "blank configured password never grants admin (even with blank submission)" do
    original = Rails.application.config.x.admin_password
    Rails.application.config.x.admin_password = nil
    begin
      post admin_login_path, params: { password: "" }
      assert_response :unauthorized
      get admin_matches_path
      assert_redirected_to admin_login_path
    ensure
      Rails.application.config.x.admin_password = original
    end
  end

  test "finishing a match with blank scores is rejected, match stays scheduled" do
    m = @tournament.matches.create!(home_team: @arg, away_team: @bra, stage: "group", group: "A", kickoff_at: 1.hour.ago)
    post admin_login_path, params: { password: "test-admin-pw" }
    patch admin_result_path(m), params: { home_score: "", away_score: "" }
    m.reload
    assert_not m.finished?, "match should not be finished with blank scores"
  end
end
