# frozen_string_literal: true

class Views::AdminLayout < Views::Base
  # active: :tournaments | :matches | :results | :resolution
  # crumbs: array de [label, href] de ancestros entre "Admin" y la página actual
  NAV = [
    [:tournaments, "Torneos",    "🏆", :admin_tournaments_path],
    [:matches,     "Partidos",   "📅", :admin_matches_path],
    [:results,     "Resultados", "✅", :admin_results_path],
    [:resolution,  "Resolución", "🏅", :admin_resolution_path],
  ].freeze

  def initialize(active:, crumbs: [])
    @active  = active
    @crumbs  = crumbs
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

  def nav_href(key)
    public_send(NAV.find { |k,| k == key }[3])
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
              a(href: public_send(NAV.find { |k,| k == (@active || :matches) }[3], admin_tournament: t.id),
                class: "flex w-full items-center justify-between gap-2") do
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
          NAV.each do |key, label, icon, _path|
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

  def breadcrumbs
    current_label = NAV.find { |k,| k == @active }&.at(1) || "Admin"
    render Components::UI::Breadcrumb.new do
      render Components::UI::BreadcrumbList.new do
        render Components::UI::BreadcrumbItem.new do
          render(Components::UI::BreadcrumbLink.new(href: admin_matches_path)) { "Admin" }
        end
        @crumbs.each do |label, href|
          render Components::UI::BreadcrumbSeparator.new
          render Components::UI::BreadcrumbItem.new do
            render(Components::UI::BreadcrumbLink.new(href: href)) { label }
          end
        end
        render Components::UI::BreadcrumbSeparator.new
        render Components::UI::BreadcrumbItem.new do
          render(Components::UI::BreadcrumbPage.new) { current_label }
        end
      end
    end
  end
end
