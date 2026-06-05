require "test_helper"

class PoolRulesUiTest < ActionDispatch::IntegrationTest
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  def register_and_login(name, email)
    post session_path, params: { name: name }
    post account_email_path, params: { email: email }
    get magic_path(Player.find_by(email: email).generate_token_for(:magic_link))
  end

  test "create form shows the rules fields" do
    register_and_login("Ana", "ana@example.com")
    get pools_path
    assert_response :success
    assert_select "input[name=exact_points]"
    assert_select "input[name=knockout_multipliers]"
  end

  test "pool page shows the rules summary and an edit form for the owner" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Duros" }
    pool = Pool.find_by(name: "Duros")
    get pool_path(pool)
    assert_response :success
    assert_match "Exacto 3", response.body
    assert_select "input[name=exact_points]"
  end
end
