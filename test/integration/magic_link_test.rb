require "test_helper"

class MagicLinkTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def login_guest(name = "Oscar")
    post session_path, params: { name: name }
  end

  test "guest saves an email: pending + email sent" do
    login_guest
    assert_emails 1 do
      post account_email_path, params: { email: "oscar@example.com" }
    end
    player = Player.find_by(email: "oscar@example.com")
    assert_not_nil player
    assert_not player.registered?
  end

  test "consuming a verify token verifies the email and logs in" do
    login_guest
    post account_email_path, params: { email: "oscar@example.com" }
    player = Player.find_by(email: "oscar@example.com")
    token = player.generate_token_for(:magic_link)
    get magic_path(token)
    assert_redirected_to account_path
    assert player.reload.registered?
  end

  test "login from a fresh session sets the cookie to the verified account" do
    t = Tournament.create!(name: "Mundial 2026")
    arg = t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    bra = t.teams.create!(name: "Brasil", code: "BRA", group: "A")
    m = t.matches.create!(stage: "group", group: "A", home_team: arg, away_team: bra, kickoff_at: 1.hour.from_now)
    account = Player.create!(name: "Ana", email: "ana@example.com", email_verified_at: Time.current)
    Prediction.create!(player: account, match: m, home_pred: 2, away_pred: 1)

    assert_emails 1 do
      post login_path, params: { email: "ana@example.com" }
    end
    token = account.generate_token_for(:magic_link)
    get magic_path(token)
    assert_redirected_to predictions_path
    get predictions_path
    assert_match "Argentina", response.body
  end

  test "login with unknown email is neutral and sends nothing" do
    assert_emails 0 do
      post login_path, params: { email: "nobody@example.com" }
    end
    assert_redirected_to root_path
  end

  test "invalid token does not log in" do
    get magic_path("not-a-real-token")
    assert_redirected_to root_path
    get predictions_path
    assert_redirected_to root_path
  end

  test "cannot save an email already used by another account" do
    Player.create!(name: "Dueña", email: "taken@example.com", email_verified_at: Time.current)
    login_guest
    post account_email_path, params: { email: "taken@example.com" }
    assert_redirected_to account_path
    assert_equal 1, Player.where(email: "taken@example.com").count
  end
end
