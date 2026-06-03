# frozen_string_literal: true

class Views::Standings::Index < Views::Base
  PODIUM_HEIGHTS = { 1 => "h-28", 2 => "h-20", 3 => "h-16" }.freeze

  def initialize(rows:, sort_dir:, podium: [])
    @rows = rows
    @sort_dir = sort_dir
    @podium = podium
  end

  def view_template
    render Views::Layout.new(active: :standings) do
      page_header("Ranking", "Los que más saben de fútbol, hasta arriba.")
      if @rows.empty?
        render Components::UI::Alert.new { "Aún no hay puntos en el ranking. ¡Que empiece el torneo!" }
      else
        podium_block
        ranking_table
      end
    end
  end

  private

  # ---- Podium (top 3) -------------------------------------------------------

  def podium_block
    return if @podium.empty?

    # Visual order: 2nd · 1st · 3rd, so the leader sits centered and tallest.
    slots = []
    slots << [@podium[1], 2] if @podium[1]
    slots << [@podium[0], 1]
    slots << [@podium[2], 3] if @podium[2]

    div(class: "mb-10 flex items-end justify-center gap-3 sm:gap-4") do
      slots.each { |row, rank| podium_spot(row, rank) }
    end
  end

  def podium_spot(row, rank)
    leader = rank == 1
    pedestal = leader ? "bg-primary/15 border-primary/40 gb-glow-sm" : "bg-muted border-border"
    div(class: "flex w-24 flex-col items-center gap-2 sm:w-28") do
      span(class: "text-xl leading-none") { leader ? "🏆" : "" }
      render(Components::UI::Avatar.new(class: leader ? "ring-2 ring-primary" : "")) do
        render(Components::UI::AvatarFallback.new) { row[:player].initials }
      end
      span(class: "max-w-full truncate text-sm font-medium") { row[:player].name }
      span(class: "font-bold #{leader ? 'text-primary' : 'text-foreground'}") { "#{row[:points]} pts" }
      div(class: "flex w-full items-start justify-center rounded-t-lg border pt-2 #{PODIUM_HEIGHTS[rank]} #{pedestal}") do
        span(class: "font-display text-3xl text-muted-foreground") { rank.to_s }
      end
    end
  end

  # ---- Full sortable table --------------------------------------------------

  def ranking_table
    render Components::UI::DataTable.new do
      render Components::UI::Table.new do
        render Components::UI::TableCaption.new { "Tabla completa" }
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

  def standing_row(row, index)
    render Components::UI::TableRow.new do
      render Components::UI::TableCell.new { (index + 1).to_s }
      render Components::UI::TableCell.new do
        div(class: "flex items-center gap-2") do
          render(Components::UI::Avatar.new) { render(Components::UI::AvatarFallback.new) { row[:player].initials } }
          span { row[:player].name }
        end
      end
      render Components::UI::TableCell.new { row[:points].to_s }
    end
  end
end
