# frozen_string_literal: true

class Views::Layout < Views::Base
  def initialize(active:)
    @active = active
  end

  def view_template(&block)
    div(class: "gb-stage min-h-screen") do
      header(class: "sticky top-0 z-30 border-b border-border bg-background/70 backdrop-blur") do
        div(class: "mx-auto flex max-w-3xl items-center justify-between gap-3 px-4 py-3") do
          brand
          div(class: "flex items-center gap-2") do
            render_nav if @active
            a(href: account_path, class: "text-sm text-muted-foreground hover:text-foreground transition") { "Mi cuenta" }
            theme_toggle
          end
        end
      end
      main(class: "mx-auto max-w-3xl px-4 py-8", &block)
      render Components::UI::Toaster.new
    end
  end

  private

  def brand
    a(href: predictions_path, class: "inline-flex shrink-0 items-center gap-2 font-display text-lg text-foreground") do
      span(class: "inline-block h-2.5 w-2.5 rounded-full bg-primary gb-glow-sm")
      span { "Golbet" }
    end
  end

  def render_nav
    nav(class: "flex items-center gap-1 rounded-full border border-border bg-muted/40 p-1") do
      pill("Grupos", groups_path, :groups)
      pill("Pronósticos", predictions_path, :predictions)
      pill("Ranking", standings_path, :standings)
      pill("Resultados", results_path, :results)
    end
  end

  def pill(label, path, key)
    active = @active == key
    state = active ? "bg-primary text-primary-foreground gb-glow-sm" : "text-muted-foreground hover:text-foreground"
    a(href: path, class: "rounded-full px-3.5 py-1.5 text-sm font-medium transition #{state}") { label }
  end
end
