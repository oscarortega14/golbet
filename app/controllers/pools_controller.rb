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
    render Views::Pools::Index.new(rows: rows, can_create: current_player.registered?,
                                   tournaments: Tournament.order(:name).to_a)
  end

  def show
    pool = current_player.pools.find(params[:id])
    render Views::Pools::Show.new(pool: pool, owner: pool.owner_id == current_player.id, rules_locked: pool.rules_locked?)
  end

  def create
    unless current_player.registered?
      redirect_to account_path, alert: "Verifica tu email para crear una polla." and return
    end
    modality = modality_params
    tournament = tournament_for(modality)
    unless tournament
      redirect_to pools_path, alert: "No hay torneo disponible." and return
    end
    pool = Pool.new(pool_rule_params.merge(modality).merge(name: params[:name], tournament: tournament, owner: current_player))
    if pool.save
      Membership.find_or_create_by!(player: current_player, pool: pool)
      session[:pool_id] = pool.id
      redirect_to pool_path(pool), notice: "¡Polla creada! Comparte el link de invitación."
    else
      redirect_to pools_path, alert: pool.errors.full_messages.first
    end
  end

  def update
    pool = current_player.owned_pools.find(params[:id])
    if pool.rules_locked?
      redirect_to pool_path(pool), alert: "El torneo ya empezó; las reglas están bloqueadas." and return
    end
    if pool.update(pool_rule_params.merge(modality_params))
      redirect_to pool_path(pool), notice: "Reglas actualizadas."
    else
      redirect_to pool_path(pool), alert: pool.errors.full_messages.first
    end
  end

  def select
    pool = current_player.pools.find_by(id: params[:id])
    session[:pool_id] = pool.id if pool
    redirect_back fallback_location: predictions_path
  end

  private

  def pool_rule_params
    params.permit(:exact_points, :outcome_points, :knockout_multipliers, :special_enabled,
                  :champion_bonus, :top_scorer_bonus)
          .to_h.reject { |_, v| v.blank? }
  end

  # Normaliza los campos de modalidad: limpia el lado que no aplica.
  # Devuelve {} si no se envió modalidad (compatibilidad con forms que solo mandan nombre/reglas).
  def modality_params
    return {} if params[:modality].blank?
    permitted = params.permit(:modality, :focus_match_id, stages: [])
    if permitted[:modality] == "match"
      { modality: "match", focus_match_id: permitted[:focus_match_id].presence, stages: nil }
    else
      { modality: "stages", stages: permitted[:stages].presence, focus_match_id: nil }
    end
  end

  # En modalidad "un partido" el torneo se deriva del partido elegido; si no, del selector.
  def tournament_for(modality)
    if modality[:modality] == "match" && modality[:focus_match_id].present?
      Match.find_by(id: modality[:focus_match_id])&.tournament || Tournament.active
    else
      Tournament.find_by(id: params[:tournament_id]) || Tournament.active
    end
  end
end
