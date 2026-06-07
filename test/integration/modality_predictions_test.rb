require "test_helper"

class ModalityPredictionsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", flag: "🇧🇷", group: "A")
    @por = @t.teams.create!(name: "Portugal", code: "POR", flag: "🇵🇹", group: "B")
    @esp = @t.teams.create!(name: "España", code: "ESP", flag: "🇪🇸", group: "B")
    @group = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.days.from_now)
    @final = @t.matches.create!(stage: "final", home_team: @por, away_team: @esp, kickoff_at: 5.days.from_now)
  end

  def use_pool(pool)
    post session_path, params: { name: "Ana" }
    Membership.create!(player: Player.find_by(name: "Ana"), pool: pool)
    post select_pool_path(pool)
  end

  test "a groups-only pool shows only group matches and no special card" do
    use_pool Pool.create!(tournament: @t, name: "Solo grupos", stages: ["group"])
    get predictions_path
    assert_response :success
    assert_match "Argentina", response.body
    assert_no_match(/Portugal/, response.body)            # la final no está en alcance
    assert_no_match(/predicción especial/, response.body) # sin tarjeta especial
  end

  test "a single-match pool shows only that match" do
    use_pool Pool.create!(tournament: @t, name: "El partidazo", modality: "match", focus_match: @group)
    get predictions_path
    assert_response :success
    assert_match "Argentina", response.body
    assert_no_match(/Portugal/, response.body)
  end

  test "a full pool shows the special card" do
    use_pool Pool.create!(tournament: @t, name: "Completa")
    get predictions_path
    assert_response :success
    assert_match "Portugal", response.body            # la final está en alcance
    assert_match "predicción especial", response.body
  end
end
