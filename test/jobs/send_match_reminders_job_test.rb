require "test_helper"

class SendMatchRemindersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @arg = @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    @bra = @t.teams.create!(name: "Brasil", code: "BRA", group: "A")
    @soon = @t.matches.create!(stage: "group", group: "A", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    @pool = Pool.create!(tournament: @t, name: "Los Cracks")
    @ana = Player.create!(name: "Ana", email: "ana@example.com", email_verified_at: Time.current)
    Membership.create!(player: @ana, pool: @pool)
  end

  test "enqueues a reminder for a registered member who hasn't predicted a match closing soon" do
    assert_enqueued_emails 1 do
      SendMatchRemindersJob.perform_now
    end
    assert MatchReminder.exists?(player: @ana, match: @soon)
  end

  test "does not remind a guest (unverified email)" do
    guest = Player.create!(name: "Guest")
    Membership.create!(player: guest, pool: @pool)
    assert_enqueued_emails 1 do # only Ana
      SendMatchRemindersJob.perform_now
    end
  end

  test "does not remind when email_reminders is off" do
    @ana.update!(email_reminders: false)
    assert_enqueued_emails 0 do
      SendMatchRemindersJob.perform_now
    end
  end

  test "does not remind a player who already predicted" do
    Prediction.new(player: @ana, pool: @pool, match: @soon, home_pred: 1, away_pred: 0).save!(validate: false)
    assert_enqueued_emails 0 do
      SendMatchRemindersJob.perform_now
    end
  end

  test "ignores matches outside the window" do
    @soon.update!(kickoff_at: 2.days.from_now)
    assert_enqueued_emails 0 do
      SendMatchRemindersJob.perform_now
    end
  end

  test "ignores matches with teams not set" do
    @soon.update!(home_team: nil, away_team: nil, home_label: "A", away_label: "B")
    assert_enqueued_emails 0 do
      SendMatchRemindersJob.perform_now
    end
  end

  test "is idempotent across runs" do
    assert_enqueued_emails 1 do
      SendMatchRemindersJob.perform_now
      SendMatchRemindersJob.perform_now
    end
  end

  test "respects pool modality (no reminder for an out-of-scope match)" do
    grupos_only = Pool.create!(tournament: @t, name: "Solo grupos", stages: ["group"])
    final = @t.matches.create!(stage: "final", home_team: @arg, away_team: @bra, kickoff_at: 2.hours.from_now)
    solo = Player.create!(name: "Solo", email: "solo@example.com", email_verified_at: Time.current)
    Membership.create!(player: solo, pool: grupos_only)
    SendMatchRemindersJob.perform_now
    assert MatchReminder.exists?(player: solo, match: @soon)       # group está en alcance
    assert_not MatchReminder.exists?(player: solo, match: final)   # la final no
  end
end
