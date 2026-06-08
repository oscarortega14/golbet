require "test_helper"

class MatchReminderTest < ActiveSupport::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @m = @t.matches.create!(stage: "group", kickoff_at: 1.hour.from_now, home_label: "A", away_label: "B")
    @p = Player.create!(name: "Ana", email: "ana@example.com")
  end

  test "is unique per player and match" do
    MatchReminder.create!(player: @p, match: @m, sent_at: Time.current)
    assert_raises(ActiveRecord::RecordNotUnique) do
      MatchReminder.create!(player: @p, match: @m, sent_at: Time.current)
    end
  end
end
