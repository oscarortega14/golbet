class Views::Memberships::New < Views::Base
  def initialize(pool:)
    @pool = pool
  end

  def view_template
    render Views::Layout.new(active: nil) do
      render Components::UI::Card.new(class: "max-w-md mx-auto mt-12") do
        render Components::UI::CardContent.new(padding: :standalone, class: "space-y-4 text-center") do
          h2(class: "font-display text-2xl") { "Te invitaron a" }
          p(class: "text-xl text-primary font-medium") { @pool.name }
          form(action: join_path(@pool.invite_token), method: "post") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            render Components::UI::Button.new(type: "submit", appearance: :primary) { "Unirme" }
          end
        end
      end
    end
  end
end
