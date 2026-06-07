# frozen_string_literal: true

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache

  # Shared section heading for the inner pages.
  def page_header(title, subtitle = nil)
    header(class: "mb-6") do
      h2(class: "font-display text-3xl text-foreground") { title }
      p(class: "mt-1 text-sm text-muted-foreground") { subtitle } if subtitle
    end
  end

  # Selector de torneo para las páginas de admin (cambia session[:admin_tournament_id]).
  def admin_tournament_selector(tournaments, current_id)
    return if tournaments.size <= 1
    form(method: "get", class: "mb-4 flex items-end gap-2", data: { turbo: false }) do
      div(class: "space-y-1.5") do
        render(Components::UI::Label.new(for_: "admin_tournament")) { "Torneo" }
        select(id: "admin_tournament", name: "admin_tournament",
               onchange: safe("this.form.submit()"),
               class: "rounded-md border border-border bg-background px-3 py-2 text-sm") do
          tournaments.each do |t|
            if t.id == current_id
              option(value: t.id, selected: true) { t.name }
            else
              option(value: t.id) { t.name }
            end
          end
        end
      end
    end
  end

  RULE_NUMBERS = [
    [:exact_points, "Puntos por marcador exacto"],
    [:outcome_points, "Puntos por acertar resultado"],
    [:champion_bonus, "Bono campeón"],
    [:top_scorer_bonus, "Bono goleador"]
  ].freeze

  STAGE_LABELS_FORM = [
    ["group", "Fase de grupos"], ["round_of_32", "Dieciseisavos"], ["round_of_16", "Octavos"],
    ["quarter_final", "Cuartos"], ["semi_final", "Semifinal"], ["third_place", "Tercer puesto"],
    ["final", "Final"]
  ].freeze

  def rules_fields(pool)
    RULE_NUMBERS.each do |attr, label_text|
      render Components::UI::Label.new(for_: attr.to_s) { label_text }
      render Components::UI::Input.new(type: "number", name: attr.to_s, id: attr.to_s, min: 0,
        value: pool.public_send(attr), class: "w-24")
    end
    rule_checkbox(:knockout_multipliers, "Multiplicadores de eliminatoria", pool)
    rule_checkbox(:special_enabled, "Predicción especial (campeón/goleador)", pool)
  end

  def rule_checkbox(attr, label_text, pool)
    label(class: "flex items-center gap-2 text-sm") do
      input(type: "hidden", name: attr.to_s, value: "0")
      attrs = { type: "checkbox", name: attr.to_s, value: "1" }
      attrs[:checked] = true if pool.public_send(attr)
      input(**attrs)
      span { label_text }
    end
  end

  # Selector de modalidad: radio (fases / un partido) + checkboxes de fases + dropdown de partido.
  # `match_options` es una colección de Match (con :tournament/:home_team/:away_team precargados).
  def modality_fields(pool, match_options)
    current = pool.modality.presence || "stages"
    selected = pool.effective_stages
    div(data: { controller: "modality-toggle" }, class: "space-y-3") do
      div(class: "flex gap-4") do
        modality_radio("stages", "Por fases", current)
        modality_radio("match", "Un solo partido", current)
      end
      div(data: { "modality-toggle-target" => "stages" }, class: "space-y-1") do
        p(class: "text-sm font-medium") { "Fases" }
        STAGE_LABELS_FORM.each do |val, label_text|
          label(class: "flex items-center gap-2 text-sm") do
            attrs = { type: "checkbox", name: "stages[]", value: val }
            attrs[:checked] = true if selected.include?(val)
            input(**attrs)
            span { label_text }
          end
        end
      end
      div(data: { "modality-toggle-target" => "match" }, class: "space-y-1") do
        render(Components::UI::Label.new(for_: "focus_match_id")) { "Partido" }
        select(id: "focus_match_id", name: "focus_match_id",
               class: "w-full rounded-md border border-border bg-background px-3 py-2 text-sm") do
          match_options.each do |m|
            txt = "#{m.tournament.name} — #{m.display_home} vs #{m.display_away}"
            if m.id == pool.focus_match_id
              option(value: m.id, selected: true) { txt }
            else
              option(value: m.id) { txt }
            end
          end
        end
      end
    end
  end

  def modality_radio(value, label_text, current)
    label(class: "flex items-center gap-2 text-sm") do
      attrs = { type: "radio", name: "modality", value: value,
                data: { action: "change->modality-toggle#switch" } }
      attrs[:checked] = true if current == value
      input(**attrs)
      span { label_text }
    end
  end

  def modality_summary(pool)
    if pool.modality == "match"
      m = pool.focus_match
      m ? "Un partido: #{m.display_home} vs #{m.display_away}" : "Un partido"
    elsif pool.full_tournament?
      "Torneo completo"
    else
      labels = pool.effective_stages.map { |s| STAGE_LABELS_FORM.to_h[s] || s }
      "Fases: #{labels.join(", ")}"
    end
  end

  def rules_summary(pool)
    mult = pool.knockout_multipliers ? "con multiplicadores" : "sin multiplicadores"
    special = pool.special_available? ? "campeón #{pool.champion_bonus} · goleador #{pool.top_scorer_bonus}" : "sin predicción especial"
    "#{modality_summary(pool)} · Exacto #{pool.exact_points} · Resultado #{pool.outcome_points} · Eliminatorias #{mult} · #{special}"
  end

  SUN_ICON = '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/></svg>'
  MOON_ICON = '<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>'

  # Light/dark toggle wired to Wabi's theme controller (persists to localStorage).
  def theme_toggle
    button(type: "button",
           aria: { label: "Cambiar entre claro y oscuro" },
           data: { action: "wabi--theme#toggleMode" },
           class: "inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-full " \
                  "border border-border text-muted-foreground transition hover:bg-muted hover:text-foreground") do
      span(class: "gb-when-dark") { raw(safe(SUN_ICON)) }
      span(class: "gb-when-light") { raw(safe(MOON_ICON)) }
    end
  end
end
