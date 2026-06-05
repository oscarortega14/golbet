class MembershipsController < ApplicationController
  def new
    @pool = Pool.find_by!(invite_token: params[:token])
    if current_player
      render Views::Memberships::New.new(pool: @pool)
    else
      session[:after_join_token] = params[:token]
      redirect_to root_path, notice: "Identifícate para unirte a #{@pool.name}."
    end
  end

  def create
    pool = Pool.find_by!(invite_token: params[:token])
    redirect_to root_path, alert: "Identifícate primero." and return unless current_player
    Membership.find_or_create_by!(player: current_player, pool: pool)
    session[:pool_id] = pool.id
    redirect_to predictions_path, notice: "¡Te uniste a #{pool.name}!"
  end
end
