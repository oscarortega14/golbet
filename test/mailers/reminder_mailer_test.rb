require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", group: "A")
    @m = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    @player = Player.create!(name: "Ana", email: "ana@example.com")
    @pool = Pool.create!(tournament: @t, name: "Los Cracks")
  end

  test "match_reminder addresses the player and names the match, pools, and link" do
    mail = ReminderMailer.match_reminder(@player, @m, [@pool])
    assert_equal ["ana@example.com"], mail.to
    assert_match "Argentina", mail.subject
    body = mail.parts.map(&:decoded).join
    assert_match "Ana", body
    assert_match "Argentina", body
    assert_match "Los Cracks", body
    assert_match %r{http://example\.com/predictions}, mail.body.encoded
  end
end
