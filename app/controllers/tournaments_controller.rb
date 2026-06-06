class TournamentsController < ApplicationController
  before_action :require_player

  def index
    rows = Tournament.order(active: :desc, name: :asc).map do |t|
      { tournament: t, status: status_for(t), pools: t.pools.count,
        current: current_pool&.tournament_id == t.id }
    end
    render Views::Tournaments::Index.new(rows: rows)
  end

  def join_general
    tournament = Tournament.find(params[:id])
    pool = general_pool_for(tournament)
    Membership.find_or_create_by!(player: current_player, pool: pool)
    session[:pool_id] = pool.id
    redirect_to predictions_path, notice: "¡Entraste a #{pool.name}!"
  end

  private

  def status_for(t)
    return "Activo" if t.active?
    return "Finalizado" if t.champion_team_id.present?
    return "En curso" if t.started?
    "Próximo"
  end
end
