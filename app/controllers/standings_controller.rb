class StandingsController < ApplicationController
  before_action :require_player

  def index
    pool = current_pool
    ranking = pool ? ScoringService.standings(pool) : [] # points desc, name asc
    podium = ranking.first(3)

    @sort_dir = params[:sort] == "asc" ? :asc : :desc
    rows = @sort_dir == :asc ? ranking.sort_by { |r| [r[:points], r[:player].name] } : ranking

    render Views::Standings::Index.new(rows: rows, sort_dir: @sort_dir, podium: podium, pool_name: current_pool&.name)
  end
end
