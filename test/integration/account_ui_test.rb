require "test_helper"

class AccountUiTest < ActionDispatch::IntegrationTest
  test "account page shows status and lets a guest save an email" do
    post session_path, params: { name: "Oscar" }
    get account_path
    assert_response :success
    assert_match "Sin cuenta guardada", response.body
    assert_select "input[name=email]"
  end

  test "entry screen offers login by email" do
    get root_path
    assert_response :success
    assert_select "form[action=?]", login_path
    assert_select "input[type=email]"
  end

  test "account requires a player" do
    get account_path
    assert_redirected_to root_path
  end
end
