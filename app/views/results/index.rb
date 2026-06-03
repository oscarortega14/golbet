# frozen_string_literal: true

class Views::Results::Index < Views::Base
  def initialize(rows:)
    @rows = rows
  end

  def view_template
    render Views::Layout.new(active: :results) do
      page_header("Resultados", "Marcadores finales y los puntos que sumaste.")
      if @rows.empty?
        render Components::UI::Alert.new { "Todavía no hay resultados." }
      else
        div(class: "space-y-3") do
          @rows.each { |row| result_card(row) }
        end
      end
    end
  end

  private

  def result_card(row)
    m = row[:match]
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "flex items-center justify-between gap-3") do
        span(class: "font-medium") do
          "#{m.home_team&.flag} #{m.display_home} #{m.home_score} - #{m.away_score} #{m.display_away} #{m.away_team&.flag}"
        end
        if row[:prediction]
          span(class: "text-sm text-muted-foreground") { "Tu pronóstico: #{row[:prediction].home_pred}-#{row[:prediction].away_pred}" }
          render(Components::UI::Badge.new) { "#{row[:points]} pts" }
        else
          render Components::UI::Badge.new(appearance: :secondary) { "Sin pronóstico" }
        end
      end
    end
  end
end
