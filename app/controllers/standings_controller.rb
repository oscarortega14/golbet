class StandingsController < ApplicationController
  before_action :require_player

  def index
    tournament = Tournament.first
    ranking = tournament ? ScoringService.standings(tournament) : [] # points desc, name asc
    podium = ranking.first(3)

    @sort_dir = params[:sort] == "asc" ? :asc : :desc
    rows = @sort_dir == :asc ? ranking.sort_by { |r| [r[:points], r[:player].name] } : ranking

    render Views::Standings::Index.new(rows: rows, sort_dir: @sort_dir, podium: podium)
  end
end
