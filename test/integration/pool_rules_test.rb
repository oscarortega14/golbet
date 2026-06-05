require "test_helper"

class PoolRulesTest < ActionDispatch::IntegrationTest
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  def register_and_login(name, email)
    post session_path, params: { name: name }
    post account_email_path, params: { email: email }
    get magic_path(Player.find_by(email: email).generate_token_for(:magic_link))
  end

  test "create persists custom rules" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Duros", exact_points: 5, outcome_points: 2,
                               champion_bonus: 30, top_scorer_bonus: 12, special_enabled: "1", knockout_multipliers: "0" }
    pool = Pool.find_by(name: "Duros")
    assert_equal 5, pool.exact_points
    assert_equal 30, pool.champion_bonus
    assert_not pool.knockout_multipliers
  end

  test "owner updates rules before kickoff" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Duros" }
    pool = Pool.find_by(name: "Duros")
    patch pool_path(pool), params: { exact_points: 7 }
    assert_equal 7, pool.reload.exact_points
  end

  test "rules locked after the tournament starts" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Duros" }
    pool = Pool.find_by(name: "Duros")
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.ago, home_label: "A", away_label: "B")
    patch pool_path(pool), params: { exact_points: 9 }
    assert_redirected_to pool_path(pool)
    assert_equal 3, pool.reload.exact_points
  end

  test "a non-owner cannot update a pool's rules" do
    owner = Player.create!(name: "Due", email: "due@example.com", email_verified_at: Time.current)
    pool = Pool.create!(tournament: @t, name: "Ajena", owner: owner)
    post session_path, params: { name: "Intruso" }
    patch pool_path(pool), params: { exact_points: 99 }
    assert_response :not_found
    assert_equal 3, pool.reload.exact_points
  end
end
