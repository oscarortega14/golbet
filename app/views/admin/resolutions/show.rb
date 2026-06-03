# frozen_string_literal: true

class Views::Admin::Resolutions::Show < Views::Base
  def initialize(tournament:, teams:)
    @tournament = tournament
    @teams = teams
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header("Resolver torneo", "Define el campeón y el goleador para otorgar los bonos.")
      render Components::UI::Card.new(class: "max-w-lg") do
        render Components::UI::CardContent.new(padding: :standalone) do
          form(action: admin_resolution_path, method: "post", class: "space-y-4") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: "patch")
            render Components::UI::Label.new(for_: "champion_team_id") { "Campeón" }
            select(name: "champion_team_id", id: "champion_team_id",
                   class: "block w-full rounded-md border border-border bg-card px-3 py-2") do
              option(value: "") { "— Sin definir —" }
              @teams.each do |team|
                attrs = { value: team.id }
                attrs[:selected] = true if team.id == @tournament.champion_team_id
                option(**attrs) { "#{team.flag} #{team.name}" }
              end
            end
            render Components::UI::Label.new(for_: "top_scorer") { "Goleador" }
            render Components::UI::Input.new(type: "text", name: "top_scorer", id: "top_scorer",
              value: @tournament.top_scorer, placeholder: "Nombre del goleador")
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar resultado" }
          end
        end
      end
    end
  end
end
