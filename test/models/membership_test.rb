require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @pool = Pool.create!(tournament: @t, name: "Los Cracks")
    @player = Player.create!(name: "Ana")
  end

  test "unique per player+pool" do
    Membership.create!(player: @player, pool: @pool)
    assert_not Membership.new(player: @player, pool: @pool).valid?
  end
end
