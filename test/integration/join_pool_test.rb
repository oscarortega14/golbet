require "test_helper"

class JoinPoolTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @owner = Player.create!(name: "Dueña", email: "due@example.com", email_verified_at: Time.current)
    @pool = Pool.create!(tournament: @t, name: "Los Cracks", owner: @owner)
  end

  test "a guest can join via the invite link" do
    post session_path, params: { name: "Invitado" }
    assert_difference -> { @pool.memberships.count }, 1 do
      post join_path(@pool.invite_token)
    end
    assert_redirected_to predictions_path
    assert Player.find_by(name: "Invitado").pools.include?(@pool)
  end

  test "joining is idempotent" do
    post session_path, params: { name: "Invitado" }
    post join_path(@pool.invite_token)
    assert_no_difference -> { Membership.count } do
      post join_path(@pool.invite_token)
    end
  end

  test "a cold-start guest is routed to join after identifying" do
    get join_path(@pool.invite_token)            # no current_player yet
    assert_redirected_to root_path
    post session_path, params: { name: "Nuevo" } # identify with a name
    assert_redirected_to join_path(@pool.invite_token)
  end
end
