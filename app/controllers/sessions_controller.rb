class SessionsController < ApplicationController
  def new
    redirect_to predictions_path and return if current_player
    render Views::Sessions::New.new
  end

  def create
    player = Player.new(name: params[:name])
    if player.save
      cookies.signed.permanent[:player_token] = player.session_token
      redirect_to predictions_path
    else
      render Views::Sessions::New.new, status: :unprocessable_entity
    end
  end
end
