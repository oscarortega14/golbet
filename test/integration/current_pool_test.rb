require "test_helper"

class CurrentPoolTest < ActionDispatch::IntegrationTest
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  test "identifying auto-joins the General pool" do
    post session_path, params: { name: "Ana" }
    get predictions_path
    player = Player.find_by(name: "Ana")
    general = Pool.general
    assert_not_nil general
    assert player.pools.include?(general)
  end
end
