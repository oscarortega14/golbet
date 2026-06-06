require "test_helper"

class TournamentsPageTest < ActionDispatch::IntegrationTest
  setup do
    @mundial = Tournament.create!(name: "Mundial 2026")   # activo
    @copa = Tournament.create!(name: "Copa América")
  end

  test "lists all tournaments" do
    post session_path, params: { name: "Ana" }
    get tournaments_path
    assert_response :success
    assert_match "Mundial 2026", response.body
    assert_match "Copa América", response.body
  end

  test "joining a tournament's General makes it the current pool" do
    post session_path, params: { name: "Ana" }
    post join_general_tournament_path(@copa)
    player = Player.find_by(name: "Ana")
    general = Pool.general_for(@copa)
    assert_not_nil general
    assert player.pools.include?(general)
    assert_redirected_to predictions_path
  end

  test "requires a player" do
    get tournaments_path
    assert_redirected_to root_path
  end
end
