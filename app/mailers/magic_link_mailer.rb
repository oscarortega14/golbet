class MagicLinkMailer < ApplicationMailer
  def link(player, purpose:)
    @purpose = purpose # :verify or :login
    @url = magic_url(player.generate_token_for(:magic_link))
    subject = purpose == :verify ? "Confirma tu cuenta en Golbet" : "Tu enlace para iniciar sesión en Golbet"
    mail(to: player.email, subject: subject)
  end
end
