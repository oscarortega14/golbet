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

  test "defaults to full-tournament stages modality" do
    pool = Pool.create!(tournament: @t, name: "Full")
    assert_equal "stages", pool.modality
    assert_equal Match::STAGES.sort, pool.effective_stages.sort
    assert pool.full_tournament?
  end

  test "matches_in_scope filters by stages" do
    g = @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    f = @t.matches.create!(stage: "final", kickoff_at: 2.hours.from_now, home_label: "C", away_label: "D")
    grupos = Pool.create!(tournament: @t, name: "Grupos", stages: ["group"])
    assert_equal [g.id], grupos.matches_in_scope.pluck(:id)
    assert_not grupos.full_tournament?
    full = Pool.create!(tournament: @t, name: "Full2")
    assert_equal [g.id, f.id].sort, full.matches_in_scope.pluck(:id).sort
  end

  test "match modality scopes to the chosen match" do
    g = @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "C", away_label: "D")
    pool = Pool.create!(tournament: @t, name: "Partidazo", modality: "match", focus_match: g)
    assert_equal [g.id], pool.matches_in_scope.pluck(:id)
    assert_not pool.full_tournament?
  end

  test "rejects an invalid modality" do
    assert_not Pool.new(tournament: @t, name: "X", modality: "weird").valid?
  end

  test "rejects stages outside the known stages" do
    assert_not Pool.new(tournament: @t, name: "X", stages: ["nope"]).valid?
  end

  test "rejects an empty explicit stages set" do
    assert_not Pool.new(tournament: @t, name: "X", stages: []).valid?
  end

  test "match modality requires a focus_match" do
    assert_not Pool.new(tournament: @t, name: "X", modality: "match").valid?
  end

  test "focus_match must belong to the pool's tournament" do
    other = Tournament.create!(name: "Otro")
    m = other.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    assert_not Pool.new(tournament: @t, name: "X", modality: "match", focus_match: m).valid?
  end

  test "special_available? requires full tournament and special_enabled" do
    assert Pool.create!(tournament: @t, name: "Full3").special_available?
    assert_not Pool.create!(tournament: @t, name: "Parcial", stages: ["group"]).special_available?
    assert_not Pool.create!(tournament: @t, name: "NoSpecial", special_enabled: false).special_available?
  end

  test "match modality rejects a non-existent focus_match" do
    pool = Pool.new(tournament: @t, name: "X", modality: "match", focus_match_id: 999_999)
    assert_not pool.valid?
    assert_includes pool.errors.attribute_names, :focus_match
  end
end
