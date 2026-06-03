# frozen_string_literal: true

class Views::Admin::Matches::Index < Views::Base
  STAGES = Match::STAGES
  GROUPS = ("A".."L").to_a

  def initialize(tournament:, matches:, filters: {})
    @tournament = tournament
    @matches = matches
    @filters = filters || {}
  end

  def view_template
    render Views::Layout.new(active: nil) do
      h2(class: "text-xl font-semibold mb-4") { "Partidos — #{@tournament.name}" }
      filter_bar
      div(class: "space-y-2") do
        @matches.each do |m|
          render Components::UI::Card.new do
            render Components::UI::CardContent.new(class: "flex justify-between items-center py-3") do
              span do
                plain "#{m.display_home} vs #{m.display_away}"
                span(class: "text-muted-foreground text-sm") { " — #{m.kickoff_at&.strftime('%d/%m %H:%M')}" }
              end
              a(href: edit_admin_match_path(m), class: "text-sm underline") { "Editar" }
            end
          end
        end
      end
    end
  end

  private

  def filter_bar
    form(method: "get", action: admin_matches_path, class: "flex flex-wrap items-end gap-2 mb-4") do
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
end
