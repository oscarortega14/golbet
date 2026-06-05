# frozen_string_literal: true

class Views::Pools::Index < Views::Base
  def initialize(rows:, can_create:)
    @rows = rows
    @can_create = can_create
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header("Mis pollas", "Crea o únete a pollas con tus amigos.")
      pool_list
      create_card
      join_note
    end
  end

  private

  def pool_list
    if @rows.empty?
      render(Components::UI::Alert.new) { "Aún no perteneces a ninguna polla." }
      return
    end
    div(class: "space-y-3") { @rows.each { |row| pool_card(row) } }
  end

  def pool_card(row)
    pool = row[:pool]
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "flex items-center justify-between gap-3") do
        div(class: "space-y-1") do
          a(href: pool_path(pool), class: "font-medium hover:underline") { pool[:name] || pool.name }
          div(class: "flex items-center gap-2") do
            render(Components::UI::Badge.new(appearance: row[:owner] ? :primary : :secondary)) do
              row[:owner] ? "Dueño" : "Miembro"
            end
            span(class: "text-xs text-muted-foreground") { "#{row[:members]} miembros" }
          end
        end
        if row[:current]
          render(Components::UI::Badge.new(appearance: :outline)) { "Activa" }
        else
          use_form(pool)
        end
      end
    end
  end

  def use_form(pool)
    form(action: select_pool_path(pool), method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Components::UI::Button.new(type: "submit", appearance: :secondary) { "Usar" }
    end
  end

  def create_card
    render Components::UI::Card.new(class: "mt-8") do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-4") do
        h3(class: "font-display text-xl text-foreground") { "Crear polla" }
        @can_create ? create_form : verify_note
      end
    end
  end

  def create_form
    form(action: pools_path, method: "post", class: "space-y-3") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      div(class: "flex-1 space-y-1.5") do
        render(Components::UI::Label.new(for_: "name")) { "Nombre de la polla" }
        render Components::UI::Input.new(id: "name", name: "name", placeholder: "Los Cracks", required: true)
      end
      div(class: "mt-3 space-y-2 rounded-md border border-border p-3") do
        p(class: "text-sm font-medium") { "Reglas" }
        rules_fields(Pool.new)
      end
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Crear" }
    end
  end

  def verify_note
    p(class: "text-sm text-muted-foreground") do
      plain "Verifica tu email para crear pollas. "
      a(href: account_path, class: "text-primary hover:underline") { "Ir a Mi cuenta" }
    end
  end

  def join_note
    render Components::UI::Card.new(class: "mt-4") do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-2") do
        h3(class: "font-display text-xl text-foreground") { "Unirme con link" }
        p(class: "text-sm text-muted-foreground") do
          "¿Te invitaron? Abre el link de invitación que te compartieron para unirte a esa polla."
        end
      end
    end
  end
end
