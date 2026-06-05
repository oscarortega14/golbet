require "test_helper"

class PoolTest < ActiveSupport::TestCase
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  test "auto-generates an invite_token and requires a name" do
    pool = Pool.create!(tournament: @t, name: "Los Cracks")
    assert pool.invite_token.present?
    assert_not Pool.new(tournament: @t).valid?
  end

  test "invite_token is unique" do
    a = Pool.create!(tournament: @t, name: "A")
    dup = Pool.new(tournament: @t, name: "B", invite_token: a.invite_token)
    assert_not dup.valid?
  end

  test ".general finds the public pool" do
    Pool.create!(tournament: @t, name: "Privada")
    g = Pool.create!(tournament: @t, name: "General", public: true)
    assert_equal g, Pool.general
  end
end
