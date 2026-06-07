# frozen_string_literal: true

class Views::Pools::Show < Views::Base
  def initialize(pool:, owner:, rules_locked:)
    @pool = pool
    @owner = owner
    @locked = rules_locked
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header(@pool.name, "Polla con tus amigos.")
      members_card
      invite_card if @owner
      rules_card
    end
  end

  private

  def rules_card
    div(class: "mt-6 rounded-lg border border-border p-4") do
      h3(class: "font-medium mb-2") { "Reglas" }
      p(class: "text-sm text-muted-foreground") { rules_summary(@pool) }
      if @owner && !@locked
        form(action: pool_path(@pool), method: "post", class: "mt-4 space-y-2") do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          input(type: "hidden", name: "_method", value: "patch")
          div(class: "space-y-2 rounded-md border border-border p-3") do
            p(class: "text-sm font-medium") { "Modalidad" }
            modality_fields(@pool, @pool.tournament.matches.includes(:tournament, :home_team, :away_team).order(:kickoff_at))
          end
          rules_fields(@pool)
          render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar reglas" }
        end
      elsif @owner && @locked
        p(class: "mt-2 text-sm text-muted-foreground") { "Reglas bloqueadas — el torneo ya empezó." }
      end
    end
  end

  def members_card
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-3") do
        h3(class: "font-display text-xl text-foreground") { "Miembros" }
        ul(class: "space-y-1") do
          @pool.players.order(:name).each do |player|
            li(class: "flex items-center gap-2") do
              span(class: "text-sm") { player.name }
              if player.id == @pool.owner_id
                render(Components::UI::Badge.new(appearance: :primary)) { "Dueño" }
              end
            end
          end
        end
      end
    end
  end

  def invite_card
    render Components::UI::Card.new(class: "mt-4") do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-2") do
        render(Components::UI::Label.new(for_: "invite")) { "Link de invitación" }
        render Components::UI::Input.new(
          id: "invite", type: "text", readonly: true,
          value: "/unirse/#{@pool.invite_token}"
        )
        p(class: "text-xs text-muted-foreground") { "Comparte este link para que se unan." }
      end
    end
  end
end
