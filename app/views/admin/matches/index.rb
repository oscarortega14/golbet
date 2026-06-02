# frozen_string_literal: true

class Views::Admin::Matches::Index < Views::Base
  def initialize(tournament:)
    @tournament = tournament
  end

  def view_template
    render Views::Layout.new(active: nil) do
      div(class: "flex justify-between items-center mb-4") do
        h2(class: "text-xl font-semibold") { "Partidos — #{@tournament.name}" }
        a(href: new_admin_match_path,
          class: "inline-flex items-center h-10 px-4 rounded-md bg-primary text-primary-foreground text-sm font-medium") { "Nuevo partido" }
      end
      div(class: "space-y-2") do
        @tournament.matches.order(:kickoff_at).each do |m|
          render Components::UI::Card.new do
            render Components::UI::CardContent.new(class: "flex justify-between py-3") do
              span { "#{m.home_team} vs #{m.away_team} — #{m.kickoff_at&.strftime('%d/%m %H:%M')}" }
              a(href: edit_admin_match_path(m), class: "text-sm underline") { "Editar" }
            end
          end
        end
      end
    end
  end
end
