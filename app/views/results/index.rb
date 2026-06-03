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
      div(class: "flex items-center justify-between gap-3 px-5 py-4") do
        span(class: "font-medium") { "#{m.home_team} #{m.home_score} - #{m.away_score} #{m.away_team}" }
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
