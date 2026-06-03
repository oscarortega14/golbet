require "test_helper"

class TeamTest < ActiveSupport::TestCase
  setup { @t = Tournament.create!(name: "Mundial 2026") }

  test "valid with name, code, group" do
    team = @t.teams.new(name: "Argentina", code: "ARG", flag: "🇦🇷", group: "A")
    assert team.valid?
  end

  test "requires name, code, group" do
    team = Team.new(tournament: @t)
    assert_not team.valid?
    assert_includes team.errors.attribute_names, :name
    assert_includes team.errors.attribute_names, :code
    assert_includes team.errors.attribute_names, :group
  end

  test "code is unique per tournament" do
    @t.teams.create!(name: "Argentina", code: "ARG", group: "A")
    dup = @t.teams.new(name: "Argelia", code: "ARG", group: "B")
    assert_not dup.valid?
  end
end
