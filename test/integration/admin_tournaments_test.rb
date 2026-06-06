require "test_helper"

class AdminTournamentsTest < ActionDispatch::IntegrationTest
  setup do
    @mundial = Tournament.create!(name: "Mundial 2026")  # activo
    post admin_login_path, params: { password: "test-admin-pw" }
  end

  test "lists tournaments" do
    get admin_tournaments_path
    assert_response :success
    assert_match "Mundial 2026", response.body
  end

  test "creating a tournament also creates its public General pool" do
    assert_difference -> { Tournament.count }, 1 do
      post admin_tournaments_path, params: { name: "Copa América" }
    end
    copa = Tournament.find_by(name: "Copa América")
    assert_not_nil Pool.general_for(copa)
  end

  test "activating a tournament deactivates the others" do
    copa = Tournament.create!(name: "Copa América")
    patch activate_admin_tournament_path(copa)
    assert copa.reload.active?
    assert_not @mundial.reload.active?
  end

  test "requires admin login" do
    reset!  # nueva sesión sin admin
    get admin_tournaments_path
    assert_redirected_to admin_login_path
  end
end
