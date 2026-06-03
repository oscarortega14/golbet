# frozen_string_literal: true

class Views::Predictions::Index < Views::Base
  def initialize(grouped:, predictions:, flash: {})
    @grouped = grouped
    @predictions = predictions
    @flash = flash
  end

  def view_template
    render Views::Layout.new(active: :predictions) do
      page_header("Tus pronósticos", "Clava los marcadores antes del pitazo inicial.")
      render_flash
      if @grouped.empty?
        render Components::UI::Alert.new { "Aún no hay partidos cargados." }
      else
        @grouped.each do |stage_label, matches|
          h3(class: "mt-8 mb-3 font-display text-2xl text-foreground") { stage_label }
          div(class: "space-y-3") { matches.each { |m| match_card(m) } }
        end
      end
    end
  end

  private

  def render_flash
    msg = @flash[:notice] || @flash[:alert]
    return unless msg
    div(class: "mb-3") { render Components::UI::Alert.new { msg } }
  end

  def match_card(match)
    pred = @predictions[match.id]
    render Components::UI::Card.new do
      render Components::UI::CardContent.new(padding: :standalone, class: "flex items-center justify-between gap-3") do
        span(class: "font-medium") { matchup(match) }
        if match.tbd?
          render Components::UI::Badge.new(appearance: :secondary) { "Por definir" }
        elsif match.locked?
          render Components::UI::Badge.new(appearance: :secondary) { "Cerrado" }
        else
          score_form(match, pred)
        end
      end
    end
  end

  def matchup(match)
    "#{flag(match.home_team)}#{match.display_home} vs #{flag(match.away_team)}#{match.display_away}"
  end

  def flag(team) = team&.flag ? "#{team.flag} " : ""

  def score_form(match, pred)
    form(action: predictions_path, method: "post", class: "flex items-center gap-2") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "match_id", value: match.id)
      render Components::UI::Input.new(type: "number", name: "home_pred", min: 0, value: pred&.home_pred, class: "w-14", required: true)
      span { "-" }
      render Components::UI::Input.new(type: "number", name: "away_pred", min: 0, value: pred&.away_pred, class: "w-14", required: true)
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar" }
    end
  end
end
