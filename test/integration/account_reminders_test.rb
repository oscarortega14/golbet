require "test_helper"

class AccountRemindersTest < ActionDispatch::IntegrationTest
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  def register_and_login(name, email)
    post session_path, params: { name: name }
    post account_email_path, params: { email: email }
    get magic_path(Player.find_by(email: email).generate_token_for(:magic_link))
  end

  test "registered player sees the reminders toggle and can turn it off" do
    register_and_login("Ana", "ana@example.com")
    get account_path
    assert_response :success
    assert_select "input[name=email_reminders]"
    patch account_path, params: { email_reminders: "0" }
    assert_not Player.find_by(email: "ana@example.com").email_reminders
  end

  test "a guest does not see the reminders toggle" do
    post session_path, params: { name: "Invitado" }
    get account_path
    assert_response :success
    assert_select "input[name=email_reminders]", false
  end
end
