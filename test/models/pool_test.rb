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

  test ".general_for finds the public pool of a tournament" do
    Pool.create!(tournament: @t, name: "Privada")
    g = Pool.create!(tournament: @t, name: "General", public: true)
    assert_equal g, Pool.general_for(@t)
  end

  test ".general_for is scoped per tournament" do
    other = Tournament.create!(name: "Copa")
    g1 = Pool.create!(tournament: @t, name: "General", public: true)
    g2 = Pool.create!(tournament: other, name: "General", public: true)
    assert_equal g1, Pool.general_for(@t)
    assert_equal g2, Pool.general_for(other)
  end

  test "only one public General per tournament is allowed" do
    Pool.create!(tournament: @t, name: "General", public: true)
    assert_raises(ActiveRecord::RecordNotUnique) do
      Pool.create!(tournament: @t, name: "General 2", public: true)
    end
  end

  test "defaults match the standard scoring" do
    pool = Pool.create!(tournament: @t, name: "Default")
    assert_equal 3, pool.exact_points
    assert_equal 1, pool.outcome_points
    assert pool.knockout_multipliers
    assert pool.special_enabled
    assert_equal 15, pool.champion_bonus
    assert_equal 10, pool.top_scorer_bonus
  end

  test "rejects negative points" do
    assert_not Pool.new(tournament: @t, name: "X", exact_points: -1).valid?
  end

  test "rules_locked? follows the tournament start" do
    pool = Pool.create!(tournament: @t, name: "P")
    assert_not pool.rules_locked?
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.ago, home_label: "A", away_label: "B")
    assert pool.reload.rules_locked?
  end
end
