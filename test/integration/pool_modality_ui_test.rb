require "test_helper"

class PoolModalityUiTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", flag: "🇧🇷", group: "A")
    @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.days.from_now)
  end

  def register_and_login(name, email)
    post session_path, params: { name: name }
    post account_email_path, params: { email: email }
    get magic_path(Player.find_by(email: email).generate_token_for(:magic_link))
  end

  test "create form shows the modality controls" do
    register_and_login("Ana", "ana@example.com")
    get pools_path
    assert_response :success
    assert_select "div[data-controller=modality-toggle]"
    assert_select "input[name=modality][value=stages]"
    assert_select "input[name=modality][value=match]"
    assert_select "input[name='stages[]'][value=group]"
    assert_select "select[name=focus_match_id]"
  end

  test "rules summary shows the modality on the pool page" do
    register_and_login("Ana", "ana@example.com")
    pool = Pool.create!(tournament: @t, name: "Grupos", stages: ["group"], owner: Player.find_by(email: "ana@example.com"))
    Membership.create!(player: pool.owner, pool: pool)
    get pool_path(pool)
    assert_response :success
    assert_match "Fases:", response.body
  end
end
