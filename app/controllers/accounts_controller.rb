class AccountsController < ApplicationController
  before_action :require_player

  def show
    render Views::Accounts::Show.new(player: current_player,
                                     flash: { notice: flash[:notice], alert: flash[:alert] })
  end

  def request_verification
    # Changing a verified account's email isn't supported in v1 (the form is hidden
    # when registered). Block the endpoint so a verified account can't be silently
    # moved to an unconfirmed address while staying "verified".
    redirect_to account_path, notice: "Tu cuenta ya está verificada." and return if current_player.registered?

    current_player.email = params[:email]
    if current_player.save
      MagicLinkMailer.link(current_player, purpose: :verify).deliver_now
      redirect_to account_path, notice: "Te enviamos un link a tu correo para confirmar tu cuenta."
    else
      redirect_to account_path, alert: current_player.errors.full_messages.first
    end
  end
end
