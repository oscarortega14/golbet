# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def view_template
    render Views::Layout.new(active: nil) do
      render Components::UI::Card.new(class: "max-w-md mx-auto mt-16") do
        render Components::UI::CardHeader.new do
          render Components::UI::CardTitle.new { "Golbet" }
          render Components::UI::CardDescription.new { "Escribe tu nombre para entrar a jugar." }
        end
        render Components::UI::CardContent.new do
          form(action: session_path, method: "post", class: "space-y-4") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            render Components::UI::Label.new(for_: "name") { "Tu nombre" }
            render Components::UI::Input.new(type: "text", name: "name", id: "name", required: true)
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Entrar a Golbet" }
          end
        end
      end
    end
  end
end
