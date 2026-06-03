# frozen_string_literal: true

class Views::Admin::Matches::Form < Views::Base
  def initialize(match:, teams:)
    @match = match
    @teams = teams
  end

  def view_template
    render Views::Layout.new(active: nil) do
      render Components::UI::Card.new(class: "max-w-lg mx-auto") do
        render Components::UI::CardContent.new(padding: :standalone) do
          form(action: admin_match_path(@match), method: "post", class: "space-y-4") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: "patch")
            p(class: "text-sm text-muted-foreground") { "#{@match.stage} · #{@match.home_label} / #{@match.away_label}" }
            team_select("home_team_id", "Equipo local", @match.home_team_id)
            team_select("away_team_id", "Equipo visitante", @match.away_team_id)
            render Components::UI::Label.new(for_: "match_kickoff_at") { "Fecha y hora" }
            render Components::UI::Input.new(type: "datetime-local", name: "match[kickoff_at]",
              id: "match_kickoff_at", value: @match.kickoff_at&.strftime("%Y-%m-%dT%H:%M"))
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar" }
          end
        end
      end
    end
  end

  private

  def team_select(field, label, selected)
    render Components::UI::Label.new(for_: "match_#{field}") { label }
    select(name: "match[#{field}]", id: "match_#{field}",
           class: "block w-full rounded-md border border-border bg-card px-3 py-2") do
      option(value: "") { "— TBD —" }
      @teams.each do |team|
        attrs = { value: team.id }
        attrs[:selected] = true if team.id == selected
        option(**attrs) { "#{team.flag} #{team.name} (#{team.group})" }
      end
    end
  end
end
