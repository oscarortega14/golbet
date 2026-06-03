# frozen_string_literal: true

class Views::Groups::Index < Views::Base
  def initialize(standings:)
    @standings = standings
  end

  def view_template
    render Views::Layout.new(active: :groups) do
      page_header("Grupos", "Tabla de posiciones de cada grupo.")
      if @standings.empty?
        render Components::UI::Alert.new { "Aún no hay grupos cargados." }
      else
        div(class: "grid gap-6 sm:grid-cols-2") do
          @standings.each { |letter, rows| group_table(letter, rows) }
        end
      end
    end
  end

  private

  def group_table(letter, rows)
    div(class: "rounded-lg border bg-card") do
      div(class: "border-b px-4 py-2 font-display text-lg") { "Grupo #{letter}" }
      render Components::UI::Table.new do
        render Components::UI::TableHeader.new do
          render Components::UI::TableRow.new do
            ["#", "Equipo", "PJ", "DG", "Pts"].each { |h| render Components::UI::TableHead.new { h } }
          end
        end
        render Components::UI::TableBody.new do
          rows.each_with_index { |row, i| group_row(row, i) }
        end
      end
    end
  end

  def group_row(row, index)
    qualifies = index < 2
    render Components::UI::TableRow.new do
      render Components::UI::TableCell.new { (index + 1).to_s }
      render Components::UI::TableCell.new do
        span(class: qualifies ? "font-medium text-primary" : "") { "#{row[:team].flag} #{row[:team].name}" }
      end
      render Components::UI::TableCell.new { row[:pj].to_s }
      render Components::UI::TableCell.new { row[:dg].to_s }
      render Components::UI::TableCell.new { row[:pts].to_s }
    end
  end
end
