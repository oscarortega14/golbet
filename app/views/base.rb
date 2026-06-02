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
