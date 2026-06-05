class PoolsController < ApplicationController
  before_action :require_player

  def index
    rows = current_player.pools.order(:name).map do |p|
      {
        pool: p,
        owner: p.owner_id == current_player.id,
        members: p.memberships.size,
        current: p.id == current_pool&.id
      }
    end
    render Views::Pools::Index.new(rows: rows, can_create: current_player.registered?)
  end

  def show
    pool = current_player.pools.find(params[:id])
    render Views::Pools::Show.new(pool: pool, owner: pool.owner_id == current_player.id)
  end

  def create
    unless current_player.registered?
      redirect_to account_path, alert: "Verifica tu email para crear una polla." and return
    end
    pool = Pool.new(name: params[:name], tournament: Tournament.first, owner: current_player)
    if pool.save
      Membership.find_or_create_by!(player: current_player, pool: pool)
      session[:pool_id] = pool.id
      redirect_to pool_path(pool), notice: "¡Polla creada! Comparte el link de invitación."
    else
      redirect_to pools_path, alert: pool.errors.full_messages.first
    end
  end

  def select
    pool = current_player.pools.find_by(id: params[:id])
    session[:pool_id] = pool.id if pool
    redirect_back fallback_location: predictions_path
  end
end
