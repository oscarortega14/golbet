# frozen_string_literal: true

class Views::AdminLayout < Views::Base
  # active: :tournaments | :matches | :results | :resolution
  # Las secciones Partidos/Resultados/Resolución viven anidadas bajo el torneo
  # actual (/admin/tournaments/:id/...), así la URL siempre dice de qué torneo se
  # trata. "Torneos" es la lista raíz (plana).
  NAV = [
    [:tournaments, "Torneos",    "🏆"],
    [:matches,     "Partidos",   "📅"],
    [:results,     "Resultados", "✅"],
    [:resolution,  "Resolución", "🏅"],
  ].freeze

  def initialize(active:)
    @active = active
  end

  def view_template(&block)
    render Components::UI::SidebarProvider.new(persist_key: "golbet-admin-sidebar") do
      render Components::UI::Sidebar.new(side: :left) do
        sidebar_header
        sidebar_content
        sidebar_footer
        render Components::UI::SidebarRail.new
      end
      render Components::UI::SidebarInset.new do
        topbar
        main(class: "flex-1 p-4 md:p-6", &block)
        render Components::UI::Toaster.new
      end
    end
  end

  private

  def tournaments
    @tournaments ||= Tournament.order(active: :desc, name: :asc).to_a
  end

  def current_tournament
    @current_tournament ||= helpers.current_admin_tournament
  end

  def section_label
    NAV.find { |k,| k == @active }&.at(1) || "Admin"
  end

  # Ruta de cada item del menú. "Torneos" es plana; el resto se anida bajo el
  # torneo actual (nil si todavía no hay torneos → el item queda no-clickable).
  def nav_href(key)
    case key
    when :tournaments then admin_tournaments_path
    when :matches     then current_tournament && admin_tournament_matches_path(current_tournament)
    when :results     then current_tournament && admin_tournament_results_path(current_tournament)
    when :resolution  then current_tournament && admin_tournament_resolution_path(current_tournament)
    end
  end

  # Al cambiar de torneo en el header, conserva la sección en la que estás.
  def switch_href(t)
    case @active
    when :results    then admin_tournament_results_path(t)
    when :resolution then admin_tournament_resolution_path(t)
    else                  admin_tournament_matches_path(t)
    end
  end

  # --- Header: marca + selector de torneo (DropdownMenu) ---
  def sidebar_header
    render Components::UI::SidebarHeader.new do
      render Components::UI::DropdownMenu.new(class: "w-full") do
        render Components::UI::DropdownMenuTrigger.new(
          class: "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left hover:bg-sidebar-accent"
        ) do
          span(class: "inline-block h-2.5 w-2.5 shrink-0 rounded-full bg-primary")
          span(class: "flex-1 truncate text-sm font-medium") { current_tournament&.name || "Golbet · Admin" }
          span(class: "text-xs text-muted-foreground") { "▾" }
        end
        render Components::UI::DropdownMenuContent.new do
          render(Components::UI::DropdownMenuLabel.new) { "Cambiar torneo" }
          tournaments.each do |t|
            render Components::UI::DropdownMenuItem.new(value: "tournament-#{t.id}") do
              a(href: switch_href(t), class: "flex w-full items-center justify-between gap-2") do
                span { t.name }
                render(Components::UI::Badge.new(appearance: :primary)) { "Activo" } if t.active?
              end
            end
          end
        end
      end
    end
  end

  # --- Content: navegación principal ---
  def sidebar_content
    render Components::UI::SidebarContent.new do
      render Components::UI::SidebarGroup.new(label: "Gestión") do
        render Components::UI::SidebarMenu.new do
          NAV.each do |key, label, icon|
            render Components::UI::SidebarMenuItem.new do
              render Components::UI::SidebarMenuButton.new(
                href: nav_href(key), active: @active == key, tooltip: label
              ) do
                span(class: "shrink-0 text-base") { icon }
                span { label }
              end
            end
          end
        end
      end
    end
  end

  # --- Footer: menú de usuario (tema + logout) ---
  def sidebar_footer
    render Components::UI::SidebarFooter.new do
      render Components::UI::DropdownMenu.new(class: "w-full") do
        render Components::UI::DropdownMenuTrigger.new(
          class: "flex w-full items-center gap-2 rounded-md px-2 py-1.5 hover:bg-sidebar-accent"
        ) do
          render Components::UI::Avatar.new(class: "h-7 w-7 shrink-0") do
            render(Components::UI::AvatarFallback.new) { "A" }
          end
          span(class: "flex-1 truncate text-left text-sm font-medium") { "Admin" }
        end
        render Components::UI::DropdownMenuContent.new do
          render Components::UI::DropdownMenuItem.new(value: "theme") do
            button(type: "button", data: { action: "wabi--theme#toggleMode" },
                   class: "flex w-full items-center gap-2 text-left") { "Cambiar tema" }
          end
          render Components::UI::DropdownMenuSeparator.new
          render Components::UI::DropdownMenuItem.new(value: "logout") do
            form(action: admin_logout_path, method: "post", class: "w-full") do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
              input(type: "hidden", name: "_method", value: "delete")
              button(type: "submit", class: "flex w-full items-center gap-2 text-left text-destructive") { "Cerrar sesión" }
            end
          end
        end
      end
    end
  end

  # --- Topbar dentro del inset: trigger + breadcrumb ---
  def topbar
    header(class: "flex h-14 items-center gap-2 border-b border-border px-4") do
      render Components::UI::SidebarTrigger.new
      render Components::UI::Separator.new(orientation: :vertical, class: "mx-1 h-6")
      breadcrumbs
    end
  end

  # Admin / Torneos                      (en la lista)
  # Admin / <torneo> / <sección>         (en una sección anidada)
  def breadcrumbs
    render Components::UI::Breadcrumb.new do
      render Components::UI::BreadcrumbList.new do
        crumb_link("Admin", admin_tournaments_path)
        if @active == :tournaments
          crumb_sep
          crumb_page("Torneos")
        else
          if (t = current_tournament)
            crumb_sep
            crumb_link(t.name, admin_tournament_matches_path(t))
          end
          crumb_sep
          crumb_page(section_label)
        end
      end
    end
  end

  def crumb_link(label, href)
    render Components::UI::BreadcrumbItem.new do
      render(Components::UI::BreadcrumbLink.new(href: href)) { label }
    end
  end

  def crumb_page(label)
    render Components::UI::BreadcrumbItem.new do
      render(Components::UI::BreadcrumbPage.new) { label }
    end
  end

  def crumb_sep
    render Components::UI::BreadcrumbSeparator.new
  end
end
