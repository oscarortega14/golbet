require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "requires a name" do
    player = Player.new
    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "generates a session_token on create" do
    player = Player.create!(name: "Oscar")
    assert player.session_token.present?
  end

  test "session_token is unique" do
    a = Player.create!(name: "A")
    dup = Player.new(name: "B", session_token: a.session_token)
    assert_not dup.valid?
  end

  test "guest player needs no email" do
    assert Player.new(name: "Invitado").valid?
  end

  test "normalizes and validates email when present" do
    p = Player.create!(name: "Ana", email: "  Ana@Example.COM ")
    assert_equal "ana@example.com", p.email
    assert_not Player.new(name: "x", email: "no-an-email").valid?
  end

  test "email is unique case-insensitively" do
    Player.create!(name: "Ana", email: "ana@example.com")
    assert_not Player.new(name: "Otra", email: "ANA@example.com").valid?
  end

  test "registered? requires a verified email" do
    pending = Player.create!(name: "Ana", email: "ana@example.com")
    assert_not pending.registered?
    pending.update!(email_verified_at: Time.current)
    assert pending.registered?
  end

  test "magic_link token round-trips and invalidates when email changes" do
    p = Player.create!(name: "Ana", email: "ana@example.com")
    token = p.generate_token_for(:magic_link)
    assert_equal p, Player.find_by_token_for(:magic_link, token)
    p.update!(email: "nuevo@example.com")
    assert_nil Player.find_by_token_for(:magic_link, token)
  end
end
