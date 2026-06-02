class StandingsController < ApplicationController
  before_action :require_player

  def index
    tournament = Tournament.first
    rows = tournament ? ScoringService.standings(tournament) : []
    @sort_dir = params[:sort] == "asc" ? :asc : :desc
    # ScoringService.standings already returns points desc, name asc.
    rows = rows.sort_by { |r| [r[:points], r[:player].name] } if @sort_dir == :asc
    render Views::Standings::Index.new(rows: rows, sort_dir: @sort_dir)
  end
end
