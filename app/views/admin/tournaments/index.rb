# frozen_string_literal: true

class Views::Admin::Tournaments::Index < Views::Base
  def initialize(tournaments:, current_id: nil)
    @tournaments = tournaments
    @current_id = current_id
  end

  def view_template
    render Views::AdminLayout.new(active: :tournaments) do
      h2(class: "text-xl font-semibold mb-4") { "Torneos" }
      create_form
      div(class: "space-y-2") { @tournaments.each { |t| tournament_row(t) } }
    end
  end

  private

  def create_form
    form(action: admin_tournaments_path, method: "post", class: "mb-6 flex items-end gap-2") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      div(class: "flex-1 space-y-1.5") do
        render(Components::UI::Label.new(for_: "name")) { "Nuevo torneo" }
        render Components::UI::Input.new(id: "name", name: "name", placeholder: "Copa América", required: true)
      end
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Crear" }
    end
  end

  def tournament_row(t)
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-3 py-3") do
        div(class: "flex items-center justify-between gap-3") do
          div(class: "space-y-1") do
            span(class: "font-medium") { t.name }
            if t.active?
              render(Components::UI::Badge.new(appearance: :primary)) { "Activo" }
            end
            span(class: "text-xs text-muted-foreground") { " · #{t.teams.count} equipos · #{t.matches.count} partidos" }
          end
          div(class: "flex items-center gap-2") do
            activate_button(t) unless t.active?
            manage_button(t)
          end
        end
        import_form(t)
      end
    end
  end

  def import_form(t)
    details(class: "text-sm") do
      summary(class: "cursor-pointer text-muted-foreground") { "Cargar fixtures (CSV)" }
      form(action: import_fixtures_admin_tournament_path(t), method: "post",
           enctype: "multipart/form-data", class: "mt-2 flex flex-wrap items-end gap-2") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        div(class: "space-y-1") do
          render(Components::UI::Label.new(for_: "teams_csv_#{t.id}")) { "Equipos" }
          input(type: "file", name: "teams_csv", id: "teams_csv_#{t.id}", accept: ".csv")
        end
        div(class: "space-y-1") do
          render(Components::UI::Label.new(for_: "matches_csv_#{t.id}")) { "Partidos" }
          input(type: "file", name: "matches_csv", id: "matches_csv_#{t.id}", accept: ".csv")
        end
        render Components::UI::Button.new(type: "submit", appearance: :secondary) { "Importar" }
      end
    end
  end

  def activate_button(t)
    form(action: activate_admin_tournament_path(t), method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "_method", value: "patch")
      render Components::UI::Button.new(type: "submit", appearance: :secondary) { "Activar" }
    end
  end

  def manage_button(t)
    form(action: select_admin_tournament_path(t), method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Components::UI::Button.new(type: "submit", appearance: :outline) { "Gestionar" }
    end
  end
end
