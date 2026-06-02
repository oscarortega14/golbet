# frozen_string_literal: true

class Views::Layout < Views::Base
  def initialize(active:)
    @active = active
  end

  def view_template(&block)
    div(class: "max-w-3xl mx-auto p-4") do
      header(class: "mb-6") do
        h1(class: "text-2xl font-bold mb-4") { "⚽ Golbet" }
        render_nav if @active
      end
      div(&block)
      render Components::UI::Toaster.new
    end
  end

  private

  def render_nav
    nav(class: "flex gap-2 border-b mb-4") do
      tab_link("Pronósticos", predictions_path, :predictions)
      tab_link("Ranking", standings_path, :standings)
      tab_link("Resultados", results_path, :results)
    end
  end

  def tab_link(label, path, key)
    active = @active == key
    a(href: path,
      class: "px-3 py-2 text-sm #{active ? 'border-b-2 border-primary font-medium' : 'text-muted-foreground'}") { label }
  end
end
