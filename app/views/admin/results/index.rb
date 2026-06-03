# frozen_string_literal: true

class Views::Admin::Results::Index < Views::Base
  STAGES = Match::STAGES
  GROUPS = ("A".."L").to_a

  def initialize(matches:, filters: {})
    @matches = matches
    @filters = filters || {}
  end

  def view_template
    render Views::Layout.new(active: nil) do
      h2(class: "text-xl font-semibold mb-4") { "Cargar resultados" }
      filter_bar
      div(class: "space-y-2") do
        @matches.each { |m| result_row(m) }
      end
    end
  end

  private

  def filter_bar
    form(method: "get", action: admin_results_path, class: "flex flex-wrap items-end gap-2 mb-4") do
      filter_select("stage", "Fase", STAGES, @filters["stage"])
      filter_select("group", "Grupo", GROUPS, @filters["group"])
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Filtrar" }
    end
  end

  def filter_select(name, label, options, current)
    div(class: "flex flex-col gap-1") do
      render Components::UI::Label.new(for_: "filter_#{name}") { label }
      select(name: name, id: "filter_#{name}",
             class: "block rounded-md border border-border bg-card px-3 py-2") do
        option(value: "") { "Todos" }
        options.each do |opt|
          attrs = { value: opt }
          attrs[:selected] = true if opt.to_s == current.to_s && current.present?
          option(**attrs) { opt }
        end
      end
    end
  end

  def result_row(match)
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(class: "py-3") do
        form(action: admin_result_path(match), method: "post", class: "flex items-center gap-2") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "_method", value: "patch")
          span(class: "flex-1") { matchup(match) }
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

  def matchup(match)
    home = "#{match.home_team&.flag} #{match.display_home}".strip
    away = "#{match.away_team&.flag} #{match.display_away}".strip
    "#{home} vs #{away}"
  end
end
