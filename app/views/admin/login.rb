# frozen_string_literal: true

class Views::Admin::Login < Views::Base
  def initialize(error: nil)
    @error = error
  end

  def view_template
    render Views::Layout.new(active: nil) do
      render Components::UI::Card.new(class: "max-w-md mx-auto mt-16") do
        render Components::UI::CardHeader.new do
          render Components::UI::CardTitle.new { "Admin" }
        end
        render Components::UI::CardContent.new do
          if @error
            div(class: "mb-3") { render Components::UI::Alert.new(appearance: :destructive) { @error } }
          end
          form(action: admin_login_path, method: "post", class: "space-y-4") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            render Components::UI::Label.new(for_: "password") { "Contraseña" }
            render Components::UI::Input.new(type: "password", name: "password", id: "password", required: true)
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Entrar" }
          end
        end
      end
    end
  end
end
