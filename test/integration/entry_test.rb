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

  test "blank name re-renders the entry form without creating a player" do
    assert_no_difference -> { Player.count } do
      post session_path, params: { name: "" }
    end
    assert_response :unprocessable_entity
  end
end
