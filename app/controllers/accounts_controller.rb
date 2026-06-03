class AccountsController < ApplicationController
  before_action :require_player

  def show
    render Views::Accounts::Show.new(player: current_player,
                                     flash: { notice: flash[:notice], alert: flash[:alert] })
  end

  def request_verification
    current_player.email = params[:email]
    if current_player.save
      MagicLinkMailer.link(current_player, purpose: :verify).deliver_now
      redirect_to account_path, notice: "Te enviamos un link a tu correo para confirmar tu cuenta."
    else
      redirect_to account_path, alert: current_player.errors.full_messages.first
    end
  end
end
