# frozen_string_literal: true

class Views::Admin::Tournaments::Index < Views::Base
  def initialize(tournaments:, current_id: nil)
    @tournaments = tournaments
    @current_id = current_id
  end

  def view_template
    render Views::Layout.new(active: nil) do
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
      render Components::UI::CardContent.new(padding: :standalone, class: "flex items-center justify-between gap-3 py-3") do
        div(class: "space-y-1") do
          span(class: "font-medium") { t.name }
          if t.active?
            render(Components::UI::Badge.new(appearance: :primary)) { "Activo" }
          end
        end
        div(class: "flex items-center gap-2") do
          activate_button(t) unless t.active?
          manage_button(t)
        end
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
