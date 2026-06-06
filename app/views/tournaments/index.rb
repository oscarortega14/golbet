# frozen_string_literal: true

class Views::Tournaments::Index < Views::Base
  def initialize(rows:)
    @rows = rows
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header("Torneos", "Entra a la quiniela general de cualquier torneo o crea la tuya.")
      if @rows.empty?
        render(Components::UI::Alert.new) { "Aún no hay torneos." }
      else
        div(class: "space-y-3") { @rows.each { |row| tournament_card(row) } }
      end
    end
  end

  private

  def tournament_card(row)
    t = row[:tournament]
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "flex items-center justify-between gap-3") do
        div(class: "space-y-1") do
          div(class: "font-medium") { t.name }
          div(class: "flex items-center gap-2") do
            render(Components::UI::Badge.new(appearance: t.active? ? :primary : :secondary)) { row[:status] }
            span(class: "text-xs text-muted-foreground") { "#{row[:pools]} pollas" }
          end
        end
        if row[:current]
          render(Components::UI::Badge.new(appearance: :outline)) { "Actual" }
        else
          join_form(t)
        end
      end
    end
  end

  def join_form(tournament)
    form(action: join_general_tournament_path(tournament), method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Components::UI::Button.new(type: "submit", appearance: :secondary) { "Entrar a la General" }
    end
  end
end
