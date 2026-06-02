# frozen_string_literal: true

class Views::Admin::Matches::Form < Views::Base
  def initialize(match:)
    @match = match
  end

  def view_template
    persisted = @match.persisted?
    url = persisted ? admin_match_path(@match) : admin_matches_path
    render Views::Layout.new(active: nil) do
      render Components::UI::Card.new(class: "max-w-lg mx-auto") do
        render Components::UI::CardContent.new(class: "py-6") do
          form(action: url, method: "post", class: "space-y-4") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "_method", value: "patch") if persisted
            text_field(:home_team, "Equipo local")
            text_field(:away_team, "Equipo visitante")
            render Components::UI::Label.new(for_: "match_kickoff_at") { "Fecha y hora" }
            kickoff = @match.kickoff_at&.strftime("%Y-%m-%dT%H:%M")
            render Components::UI::Input.new(type: "datetime-local", name: "match[kickoff_at]",
              id: "match_kickoff_at", value: kickoff, required: true)
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar" }
          end
        end
      end
    end
  end

  private

  def text_field(attr, label)
    render Components::UI::Label.new(for_: "match_#{attr}") { label }
    render Components::UI::Input.new(type: "text", name: "match[#{attr}]",
      id: "match_#{attr}", value: @match.public_send(attr), required: true)
  end
end
