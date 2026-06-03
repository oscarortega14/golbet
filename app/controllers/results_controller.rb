class ResultsController < ApplicationController
  before_action :require_player

  def index
    tournament = Tournament.first
    matches = tournament ? tournament.matches.where(status: "finished").includes(:home_team, :away_team).order(kickoff_at: :desc) : []
    my_preds = current_player.predictions.index_by(&:match_id)
    rows = matches.map do |m|
      pred = my_preds[m.id]
      { match: m, prediction: pred, points: pred ? ScoringService.points_for(pred, m) : nil }
    end
    render Views::Results::Index.new(rows: rows)
  end
end
