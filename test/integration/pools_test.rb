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
end
