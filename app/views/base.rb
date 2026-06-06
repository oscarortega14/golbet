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

  def rules_summary(pool)
    mult = pool.knockout_multipliers ? "con multiplicadores" : "sin multiplicadores"
    special = pool.special_enabled ? "campeón #{pool.champion_bonus} · goleador #{pool.top_scorer_bonus}" : "sin predicción especial"
    "Exacto #{pool.exact_points} · Resultado #{pool.outcome_points} · Eliminatorias #{mult} · #{special}"
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
