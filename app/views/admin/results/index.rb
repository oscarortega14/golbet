# frozen_string_literal: true

class Views::Admin::Results::Index < Views::Base
  def initialize(matches:)
    @matches = matches
  end

  def view_template
    render Views::Layout.new(active: nil) do
      h2(class: "text-xl font-semibold mb-4") { "Cargar resultados" }
      div(class: "space-y-2") do
        @matches.each { |m| result_row(m) }
      end
    end
  end

  private

  def result_row(match)
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(class: "py-3") do
        form(action: admin_result_path(match), method: "post", class: "flex items-center gap-2") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "_method", value: "patch")
          span(class: "flex-1") { "#{match.home_team} vs #{match.away_team}" }
          render Components::UI::Input.new(type: "number", name: "home_score", min: 0,
            value: match.home_score, class: "w-14")
          span { "-" }
          render Components::UI::Input.new(type: "number", name: "away_score", min: 0,
            value: match.away_score, class: "w-14")
          render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar resultado" }
          render(Components::UI::Badge.new) { "Finalizado" } if match.finished?
        end
      end
    end
  end
end
