class Views::Accounts::Show < Views::Base
  def initialize(player:, flash: {})
    @player = player
    @flash = flash
  end

  def view_template
    render Views::Layout.new(active: nil) do
      page_header("Mi cuenta", "Guarda tu cuenta para no perder tus pronósticos.")
      render_flash
      render Components::UI::Card.new(class: "max-w-lg") do
        render Components::UI::CardContent.new(padding: :standalone, class: "space-y-4") do
          p(class: "text-sm text-muted-foreground") { "Jugando como" }
          p(class: "font-medium") { @player.name }
          status_line
          email_form unless @player.registered?
          sign_out_form
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

  def status_line
    if @player.registered?
      render(Components::UI::Badge.new) { "✓ #{@player.email}" }
    elsif @player.email.present?
      render(Components::UI::Badge.new(appearance: :secondary)) { "Pendiente: #{@player.email}" }
    else
      render(Components::UI::Badge.new(appearance: :secondary)) { "Sin cuenta guardada" }
    end
  end

  def email_form
    form(action: account_email_path, method: "post", class: "flex items-center gap-2") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      render Components::UI::Input.new(type: "email", name: "email", placeholder: "tu@email.com",
        value: @player.email, required: true, class: "flex-1")
      render Components::UI::Button.new(type: "submit", appearance: :primary) { "Guardar cuenta" }
    end
  end

  def sign_out_form
    form(action: session_path, method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "_method", value: "delete")
      render Components::UI::Button.new(type: "submit", appearance: :secondary) { "Cerrar sesión" }
    end
  end
end
