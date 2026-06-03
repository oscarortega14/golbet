require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  setup { @player = Player.create!(name: "Ana", email: "ana@example.com") }

  test "verify email contains a magic link and verify wording" do
    mail = MagicLinkMailer.link(@player, purpose: :verify)
    body = mail.parts.map(&:decoded).join
    assert_equal ["ana@example.com"], mail.to
    assert_match %r{http://example\.com/magic/}, mail.body.encoded
    assert_match "verific", body.downcase
  end

  test "login email uses session wording" do
    mail = MagicLinkMailer.link(@player, purpose: :login)
    body = mail.parts.map(&:decoded).join
    assert_match %r{http://example\.com/magic/}, mail.body.encoded
    assert_match "sesión", body
  end
end
