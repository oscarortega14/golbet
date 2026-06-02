class SessionsController < ApplicationController
  def new
    redirect_to predictions_path and return if current_player
    render Views::Sessions::New.new
  end

  def create
    player = Player.create!(name: params[:name])
    cookies.signed.permanent[:player_token] = player.session_token
    redirect_to predictions_path
  end
end
