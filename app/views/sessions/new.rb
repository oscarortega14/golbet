# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def view_template
    main(class: "gb-stage gb-grain min-h-screen flex flex-col") do
      header(class: "flex items-center justify-between px-6 py-5") do
        brand
        div(class: "flex items-center gap-3") do
          a(href: "#jugar",
            class: "text-sm text-muted-foreground hover:text-foreground transition") { "¿Cómo funciona?" }
          theme_toggle
        end
      end

      section(id: "jugar", class: "flex-1 flex items-center px-6 pb-16") do
        div(class: "mx-auto w-full max-w-3xl") do
          div(class: "gb-chip gb-rise mb-7", style: "animation-delay:.05s") do
            span(class: "text-primary") { "⚽" }
            span { "Mundial 2026 · La quiniela entre amigos" }
          end

          h1(class: "font-display text-foreground text-6xl sm:text-8xl") do
            span(class: "block gb-rise", style: "animation-delay:.10s") { "Pronostica." }
            span(class: "block gb-rise", style: "animation-delay:.18s") { "Apuesta." }
            span(class: "block gb-rise text-primary", style: "animation-delay:.26s") { "Presume." }
          end

          p(class: "mt-7 max-w-md text-lg text-muted-foreground gb-rise", style: "animation-delay:.36s") do
            "Arma tu quiniela, clava los marcadores y trepa al ranking. El que más sabe de fútbol, gana."
          end

          form(action: session_path, method: "post",
               class: "mt-9 flex w-full max-w-md gap-2 gb-rise", style: "animation-delay:.46s") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "text", name: "name", id: "name", required: true,
                  placeholder: "Tu nombre",
                  class: "flex-1 h-12 rounded-xl bg-card border border-border px-4 text-foreground " \
                         "placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary")
            button(type: "submit",
                   class: "gb-glow h-12 shrink-0 rounded-xl bg-primary px-6 font-semibold " \
                          "text-primary-foreground transition hover:brightness-110") { "Entrar ▸" }
          end

          div(class: "mt-10 flex flex-wrap gap-3 gb-rise", style: "animation-delay:.58s") do
            stat("3·1·0", "puntos por acierto")
            stat("⚡", "ranking al instante")
            stat("🏆", "presume tu corona")
          end
        end
      end
    end
  end

  private

  def brand
    a(href: root_path, class: "inline-flex items-center gap-2 font-display text-xl text-foreground") do
      span(class: "inline-block h-2.5 w-2.5 rounded-full bg-primary gb-glow-sm")
      span { "Golbet" }
    end
  end

  def stat(value, label)
    div(class: "gb-chip") do
      span(class: "font-semibold text-foreground") { value }
      span { label }
    end
  end
end
