require "test_helper"

class StandingsTest < ActionDispatch::IntegrationTest
  setup do
    @t = Tournament.create!(name: "Mundial 2026")
    @m = @t.matches.create!(home_team: "ARG", away_team: "BRA",
      kickoff_at: 2.hours.ago, status: "finished", home_score: 2, away_score: 1)
    @ana = Player.create!(name: "Ana")
    @beto = Player.create!(name: "Beto")
    # predictions on a finished (locked) match: bypass the kickoff-lock validation for setup
    Prediction.new(player: @ana, match: @m, home_pred: 2, away_pred: 1).save!(validate: false)  # exact = 3
    Prediction.new(player: @beto, match: @m, home_pred: 1, away_pred: 0).save!(validate: false) # outcome = 1
  end

  def login(name = "Viewer")
    post session_path, params: { name: name }
  end

  test "ranking lists players by points desc by default" do
    login
    get standings_path
    assert_response :success
    body = response.body
    # Ana (3) should appear before Beto (1) — scope to tbody to avoid nav false positives
    tbody_start = body.index("<tbody")
    tbody_end   = body.index("</tbody>")
    tbody = body[tbody_start..tbody_end]
    assert_operator tbody.index("Ana"), :<, tbody.index("Beto")
    assert_match "3", body
  end

  test "sort=asc reverses the order (Beto with 1pt first)" do
    login
    get standings_path(sort: "asc")
    assert_response :success
    body = response.body
    tbody_start = body.index("<tbody")
    tbody_end   = body.index("</tbody>")
    tbody = body[tbody_start..tbody_end]
    assert_operator tbody.index("Beto"), :<, tbody.index("Ana")
  end

  test "the Puntos column header is a sort toggle link" do
    login
    get standings_path
    assert_response :success
    # default desc -> link toggles to asc
    assert_select "a[href=?]", standings_path(sort: "asc")
  end

  test "requires a player" do
    get standings_path
    assert_redirected_to root_path
  end
end
