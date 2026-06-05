# frozen_string_literal: true

class Views::Pools::Show < Views::Base
  def initialize(pool:, owner:)
    @pool = pool
    @owner = owner
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header(@pool.name, "Polla con tus amigos.")
      members_card
      invite_card if @owner
    end
  end

  private

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
