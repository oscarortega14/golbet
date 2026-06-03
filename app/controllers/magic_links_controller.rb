class MagicLinksController < ApplicationController
  def request_login
    email = params[:email].to_s.strip.downcase
    player = Player.where.not(email_verified_at: nil).find_by(email: email)
    MagicLinkMailer.link(player, purpose: :login).deliver_now if player
    redirect_to root_path, notice: "Si existe una cuenta con ese correo, te enviamos un link para entrar."
  end

  def consume
    player = Player.find_by_token_for(:magic_link, params[:token])
    if player.nil?
      redirect_to root_path, alert: "El enlace es inválido o expiró. Pide uno nuevo." and return
    end

    was_verified = player.registered?
    player.update!(email_verified_at: Time.current) unless was_verified
    cookies.signed.permanent[:player_token] = player.session_token

    if was_verified
      redirect_to predictions_path, notice: "¡Sesión iniciada!"
    else
      redirect_to account_path, notice: "¡Cuenta confirmada! Ya puedes entrar desde cualquier dispositivo."
    end
  end
end
