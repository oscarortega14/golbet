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
end
