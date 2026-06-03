require "test_helper"

class KnockoutBracketBuilderTest < ActiveSupport::TestCase
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  test "creates the full knockout skeleton as TBD" do
    KnockoutBracketBuilder.new(@t).build
    counts = @t.matches.where.not(stage: "group").group(:stage).count
    assert_equal 16, counts["round_of_32"]
    assert_equal 8,  counts["round_of_16"]
    assert_equal 4,  counts["quarter_final"]
    assert_equal 2,  counts["semi_final"]
    assert_equal 1,  counts["third_place"]
    assert_equal 1,  counts["final"]
    sample = @t.matches.find_by(stage: "round_of_32", slot: 1)
    assert sample.tbd?
    assert sample.home_label.present?
    assert sample.kickoff_at.present?
  end

  test "is idempotent" do
    KnockoutBracketBuilder.new(@t).build
    KnockoutBracketBuilder.new(@t).build
    assert_equal 32, @t.matches.where.not(stage: "group").count
  end
end
