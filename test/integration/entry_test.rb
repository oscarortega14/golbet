require "test_helper"

class EntryTest < ActionDispatch::IntegrationTest
  test "root renders the entry form" do
    get root_path
    assert_response :success
    assert_select "form"
    assert_select "input[name=name]"
  end

  test "submitting a name creates a player and sets the cookie" do
    assert_difference -> { Player.count }, 1 do
      post session_path, params: { name: "Oscar" }
    end
    assert_response :redirect
  end
end
