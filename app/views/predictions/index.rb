# frozen_string_literal: true

class Views::Predictions::Index < Views::Base
  def initialize(grouped:, predictions:, special: nil, teams: [], tournament: nil, flash: {})
    @grouped = grouped
    @predictions = predictions
    @special = special
    @teams = teams
    @tournament = tournament
    @flash = flash
  end

  def view_template
    render Views::Layout.new(active: :predictions) do
      page_header("Tus pronósticos", "Clava los marcadores antes del pitazo inicial.")
      render_flash
      special_card if @special
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

  def special_card
    locked = @tournament&.started?
    render Components::UI::Card.new(class: "mb-8") do
      render Components::UI::CardContent.new(padding: :standalone, class: "space-y-3") do
        h3(class: "font-display text-xl text-foreground") { "🏆 Tu predicción especial" }
        locked ? special_readonly : special_form
      end
    end
  end

  def special_form
    form(action: special_prediction_path, method: "post", class: "space-y-3") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Components::UI::Label.new(for_: "champion_team_id") { "Campeón" }
      select(name: "champion_team_id", id: "champion_team_id",
             class: "block w-full rounded-md border border-border bg-card px-3 py-2") do
        option(value: "") { "— Elige un equipo —" }
        @teams.each do |team|
          attrs = { value: team.id }
          attrs[:selected] = true if team.id == @special.champion_team_id
          option(**attrs) { "#{team.flag} #{team.name}" }
        end
      end
      render Components::UI::Label.new(for_: "top_scorer") { "Goleador del torneo" }
      render Components::UI::Input.new(type: "text", name: "top_scorer", id: "top_scorer",
        value: @special.top_scorer, placeholder: "Nombre del jugador")
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar predicción" }
    end
  end

  def special_readonly
    div(class: "text-sm space-y-1") do
      p { "Campeón: #{champion_line}" }
      p { "Goleador: #{scorer_line}" }
    end
  end

  def champion_line
    pick = @special.champion_team
    return "—" unless pick
    real = @tournament.champion_team
    mark = real ? (real.id == pick.id ? " ✓" : " ✗") : ""
    "#{pick.flag} #{pick.name}#{mark}"
  end

  def scorer_line
    return "—" if @special.top_scorer.blank?
    real = @tournament.top_scorer
    mark = real ? (SpecialPrediction.normalize(real) == SpecialPrediction.normalize(@special.top_scorer) ? " ✓" : " ✗") : ""
    "#{@special.top_scorer}#{mark}"
  end

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
