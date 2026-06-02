# frozen_string_literal: true

class Views::Standings::Index < Views::Base
  def initialize(rows:, sort_dir:)
    @rows = rows
    @sort_dir = sort_dir
  end

  def view_template
    render Views::Layout.new(active: :standings) do
      render Components::UI::DataTable.new do
        render Components::UI::Table.new do
          render Components::UI::TableCaption.new { "Ranking de Golbet" }
          render Components::UI::TableHeader.new do
            render Components::UI::TableRow.new do
              render Components::UI::TableHead.new { "#" }
              render Components::UI::TableHead.new { "Jugador" }
              render Components::UI::TableHead.new do
                render Components::UI::DataTableColumnHeader.new(
                  href: standings_path(sort: (@sort_dir == :desc ? "asc" : "desc")),
                  sorted: @sort_dir
                ) { "Puntos" }
              end
            end
          end
          render Components::UI::TableBody.new do
            @rows.each_with_index { |row, i| standing_row(row, i) }
          end
        end
      end
    end
  end

  private

  def standing_row(row, index)
    render Components::UI::TableRow.new do
      render Components::UI::TableCell.new { (index + 1).to_s }
      render Components::UI::TableCell.new do
        div(class: "flex items-center gap-2") do
          render(Components::UI::Avatar.new) { render(Components::UI::AvatarFallback.new) { row[:player].initials } }
          span { row[:player].name }
          render(Components::UI::Badge.new) { "🏆" } if index.zero? && row[:points].positive?
        end
      end
      render Components::UI::TableCell.new { row[:points].to_s }
    end
  end
end
