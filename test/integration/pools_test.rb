require "test_helper"

class PoolsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @copa = Tournament.create!(name: "Copa América")
  end

  def register_and_login(name, email)
    post session_path, params: { name: name }
    post account_email_path, params: { email: email }
    player = Player.find_by(email: email)
    get magic_path(player.generate_token_for(:magic_link)) # verifies email
  end

  test "a registered player creates a pool and becomes owner+member" do
    register_and_login("Ana", "ana@example.com")
    assert_difference -> { Pool.count }, 1 do
      post pools_path, params: { name: "Los Cracks" }
    end
    pool = Pool.find_by(name: "Los Cracks")
    assert_equal "ana@example.com", pool.owner.email
    assert pool.players.exists?(pool.owner_id)
    assert_redirected_to pool_path(pool)
  end

  test "a guest cannot create a pool" do
    post session_path, params: { name: "Invitado" }
    get pools_path # triggers General pool auto-creation before we assert
    assert_no_difference -> { Pool.count } do
      post pools_path, params: { name: "Nope" }
    end
    assert_redirected_to account_path
  end

  test "Mis pollas lists the player's pools" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Los Cracks" }
    get pools_path
    assert_response :success
    assert_match "Los Cracks", response.body
  end

  test "creating a pool uses the chosen tournament" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Cracks Copa", tournament_id: @copa.id }
    pool = Pool.find_by(name: "Cracks Copa")
    assert_equal @copa, pool.tournament
  end

  test "creating a pool without tournament_id falls back to the active tournament" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Cracks" }
    pool = Pool.find_by(name: "Cracks")
    assert_equal @t, pool.tournament   # @t es el activo (primero creado)
  end

  test "creating a stages pool with a subset persists the stages" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Grupos", modality: "stages", stages: ["group", "final"] }
    pool = Pool.find_by(name: "Grupos")
    assert_equal "stages", pool.modality
    assert_equal ["final", "group"], pool.effective_stages.sort
    assert_not pool.full_tournament?
  end

  test "creating a match pool derives the tournament from the chosen match" do
    m = @copa.matches.create!(stage: "group", group: "A", home_label: "X", away_label: "Y", kickoff_at: 1.day.from_now)
    register_and_login("Ana", "ana@example.com")
    # tournament_id apunta a @t, pero el partido es de @copa → el torneo debe seguir al partido
    post pools_path, params: { name: "Partidazo", modality: "match", focus_match_id: m.id, tournament_id: @t.id }
    pool = Pool.find_by(name: "Partidazo")
    assert_equal "match", pool.modality
    assert_equal @copa, pool.tournament
    assert_equal m, pool.focus_match
  end

  test "owner edits modality before the tournament starts" do
    register_and_login("Ana", "ana@example.com")
    post pools_path, params: { name: "Editable" }
    pool = Pool.find_by(name: "Editable")
    patch pool_path(pool), params: { modality: "stages", stages: ["group"] }
    assert_equal ["group"], pool.reload.effective_stages
  end
end
