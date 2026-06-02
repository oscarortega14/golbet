require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
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

  test "admin creates a match" do
    post admin_login_path, params: { password: "test-admin-pw" }
    assert_difference -> { Match.count }, 1 do
      post admin_matches_path, params: { match: {
        home_team: "ARG", away_team: "BRA",
        kickoff_at: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
      } }
    end
    assert_redirected_to admin_matches_path
    follow_redirect!
    assert_match "ARG vs BRA", response.body
  end

  test "new match form renders fields" do
    post admin_login_path, params: { password: "test-admin-pw" }
    get new_admin_match_path
    assert_response :success
    assert_select "input[name=?]", "match[home_team]"
    assert_select "input[name=?]", "match[kickoff_at]"
  end

  test "admin enters a result, match becomes finished and scoring reflects it" do
    t = Tournament.create!(name: "Torneo")
    m = t.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.ago)
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
    t = Tournament.create!(name: "Torneo")
    m = t.matches.create!(home_team: "ARG", away_team: "BRA", kickoff_at: 1.hour.ago)
    post admin_login_path, params: { password: "test-admin-pw" }
    patch admin_result_path(m), params: { home_score: "", away_score: "" }
    m.reload
    assert_not m.finished?, "match should not be finished with blank scores"
  end
end
